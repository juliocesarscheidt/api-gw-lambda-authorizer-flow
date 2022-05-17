import os
import jwt
import json
import boto3
import bcrypt

from datetime import datetime
from base64 import b64decode

dynamodb_client = boto3.client("dynamodb")
kms_client = boto3.client("kms")


def decrypt_secret(secret_name):
    SECRET = os.environ[secret_name]
    if os.environ.get("ENV") == "local":
        return SECRET
    return kms_client.decrypt(
        CiphertextBlob=b64decode(SECRET),
        EncryptionContext={
            "LambdaFunctionName": os.environ["AWS_LAMBDA_FUNCTION_NAME"]
        },
    )["Plaintext"].decode("utf-8")


JWT_SECRET = os.environ["JWT_SECRET"]
ENV = os.environ["ENV"]

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
        print(e)
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
        print(e)
        return {
            "statusCode": "500",
            "body": json.dumps({"message": "Internal Server Error"}),
            "headers": DEFAULT_HEADERS,
        }

    if "Item" not in response or response["Item"] is None:
        print("Failed - Not Found")
        return {
            "statusCode": "404",
            "body": json.dumps({"message": "Not Found"}),
            "headers": DEFAULT_HEADERS,
        }

    data = format_user_data(response["Item"])

    if not bcrypt.checkpw(str.encode(password), str.encode(data["password"])):
        print("Failed - Unauthorized")
        return {
            "statusCode": "401",
            "body": json.dumps({"message": "Unauthorized"}),
            "headers": DEFAULT_HEADERS,
        }

    token = generate_token({"email": data["email"], "username": data["username"],})
    print("token", token)

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
            "statusCode": "500",
            "body": json.dumps({"message": "Internal Server Error"}),
            "headers": DEFAULT_HEADERS,
        }
    return response


def handler(event=None, context=None, callback=None):
    print("event", event)
    print("context", context)
    print("callback", callback)

    body = json.loads(event["body"])
    print("body", body)

    return handle_event(event["path"], body)


if ENV == "local":
    event = {
        "resource": "/signin",
        "path": "/signin",
        "httpMethod": "POST",
        "headers": {},
        "multiValueHeaders": {},
        "queryStringParameters": None,
        "multiValueQueryStringParameters": None,
        "pathParameters": None,
        "stageVariables": None,
        "requestContext": {
            "resourceId": "aaaa",
            "resourcePath": "/signin",
            "httpMethod": "POST",
            "extendedRequestId": "A=",
            "requestTime": "15/May/2022:00:00:00 +0000",
            "path": "/authorizer/signin",
            "accountId": "000000000000",
            "protocol": "HTTP/1.1",
            "stage": "authorizer",
            "domainPrefix": "aaaa",
            "requestTimeEpoch": 0,
            "requestId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
            "identity": {},
            "domainName": "",
            "apiId": "aaaa",
        },
        "body": '{"email": "julioscheidt@mail.com", "password": "PASSWORD"}',
        "isBase64Encoded": False,
    }

    def callable_fn_mock(response=None, value=None):
        pass

    handler(event, None, callable_fn_mock)
