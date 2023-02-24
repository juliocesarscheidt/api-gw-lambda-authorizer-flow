import os
import jwt
import json
import boto3
import bcrypt
import logging

from datetime import datetime
from base64 import b64decode

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s",
)
logger = logging.getLogger()

dynamodb_client = boto3.client("dynamodb")
kms_client = boto3.client("kms")
ssm = boto3.client("ssm")


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


DYNAMODB_TABLE_NAME = f"users_tbl_{ENV}"
DEFAULT_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "OPTIONS,POST",
}


def generate_token(payload: dict) -> str:
    now = datetime.now()
    timestamp = datetime.timestamp(now)
    payload.update(
        {"iat": timestamp, "exp": timestamp + (60 * 60 * 1)}  # timestamp plus 1 hour
    )
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")


def format_user_data(item):
    response_dict = dict(item)
    return dict(
        {
            "email": response_dict["email"]["S"],
            "username": response_dict["username"]["S"],
            "password": response_dict["password"]["S"],
        }
    )


def do_signup(body):
    email = body["email"]
    username = body["username"]
    password = body["password"]
    hashed_password = bcrypt.hashpw(str.encode(password), bcrypt.gensalt())

    try:
        dynamodb_client.put_item(
            Item={
                "email": {"S": email},
                "username": {"S": username},
                "password": {"S": hashed_password.decode()},
            },
            ReturnConsumedCapacity="TOTAL",
            TableName=DYNAMODB_TABLE_NAME,
        )
    except Exception as e:
        logger.error(e)
        return {
            "statusCode": "500",
            "body": json.dumps({"message": "Internal Server Error"}),
            "headers": DEFAULT_HEADERS,
        }

    return {
        "statusCode": "201",
        "body": json.dumps({"message": "Created"}),
        "headers": DEFAULT_HEADERS,
    }


def do_signin(body):
    email = body["email"]
    password = body["password"]

    try:
        response = dynamodb_client.get_item(
            Key={"email": {"S": email}},
            ReturnConsumedCapacity="TOTAL",
            TableName=DYNAMODB_TABLE_NAME,
        )
    except Exception as e:
        logger.error(e)
        return {
            "statusCode": "500",
            "body": json.dumps({"message": "Internal Server Error"}),
            "headers": DEFAULT_HEADERS,
        }

    if "Item" not in response or response["Item"] is None:
        logger.info("Failed - Not Found")
        return {
            "statusCode": "404",
            "body": json.dumps({"message": "Not Found"}),
            "headers": DEFAULT_HEADERS,
        }

    data = format_user_data(response["Item"])

    if not bcrypt.checkpw(str.encode(password), str.encode(data["password"])):
        logger.info("Failed - Unauthorized")
        return {
            "statusCode": "401",
            "body": json.dumps({"message": "Unauthorized"}),
            "headers": DEFAULT_HEADERS,
        }

    token = generate_token({"email": data["email"], "username": data["username"],})
    logger.info("token " + str(token))

    return {
        "statusCode": "200",
        "body": json.dumps({"token": token}),
        "headers": DEFAULT_HEADERS,
    }


def handle_event(path, body):
    if path == "/signin":
        response = do_signin(body)
    elif path == "/signup":
        response = do_signup(body)
    else:
        response = {
            "statusCode": "405",
            "body": json.dumps({"message": "Method Not Allowed"}),
            "headers": DEFAULT_HEADERS,
        }
    return response


def handler(event=None, context=None, callback=None):
    logger.info(event)
    logger.info(context)
    logger.info(callback)

    body = json.loads(event["body"])
    return handle_event(event["path"], body)
