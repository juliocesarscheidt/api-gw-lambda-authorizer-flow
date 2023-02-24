import os
import jwt
import boto3
import logging

from datetime import datetime
from base64 import b64decode

kms_client = boto3.client("kms")
ssm = boto3.client("ssm")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s",
)
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def decrypt_secret(secret_name):
    return kms_client.decrypt(
        CiphertextBlob=b64decode(os.environ[secret_name]),
        EncryptionContext={
            "LambdaFunctionName": os.environ["AWS_LAMBDA_FUNCTION_NAME"]
        },
    )["Plaintext"].decode("utf-8")


def get_ssm_parameter(env):
    return ssm.get_parameter(Name=f"/lambda/{env}/jwt-secret", WithDecryption=True)[
        "Parameter"
    ]["Value"]


ENV = os.environ["ENV"]
JWT_SECRET = get_ssm_parameter(ENV)


def generate_policy(principal_id, effect, resource, context=None):
    """
    The intention of this method is to generate a AWS policy allowing
    or denying some principal from doing some action on the specified
    resource, the policy will be something like this:
    {
      "principalId": "principal_id",
      "policyDocument": {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": "execute-api:Invoke",
            "Effect": "Allow",
            "Resource": "arn:aws:execute-api:us-east-1:XXXXXXXXXXXX:abc1234abc/*/GET/"
        ]
      }
    }
    """
    auth_response = {
        "principalId": principal_id,
    }

    if effect is not None and resource is not None:
        stmt = {
            "Action": "execute-api:Invoke",
            "Effect": effect,
            "Resource": resource,
        }
        policy_document = {
            "Version": "2012-10-17",
            "Statement": [stmt],
        }
        auth_response.update(
            {"policyDocument": policy_document,}
        )
    if context is not None and "username" in context and "email" in context:
        auth_response.update(
            {"context": {"username": context["username"], "email": context["email"]}}
        )

    logger.info(auth_response)
    return auth_response


def handler(event=None, context=None, callback=None):
    logger.info(event)
    logger.info(context)
    logger.info(callback)

    resource = event["methodArn"]
    logger.info(resource)

    token = event["authorizationToken"]
    logger.info(token)

    if token is None or token == "":
        return generate_policy("anonymous", "Deny", resource)

    try:
        token_decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        logger.info(token_decoded)
    except Exception as e:
        logger.error(e)
        return generate_policy("anonymous", "Deny", resource)

    if "username" not in token_decoded or "email" not in token_decoded:
        logger.info("Invalid username or email")
        return generate_policy("anonymous", "Deny", resource)

    principal_id = token_decoded["email"]

    now = datetime.now()
    timestamp = datetime.timestamp(now)

    if "exp" not in token_decoded or token_decoded["exp"] < timestamp:
        logger.info("Token invalid or has expired")
        return generate_policy(principal_id, "Deny", resource, token_decoded)

    return generate_policy(principal_id, "Allow", resource, token_decoded)
