import os
import sys
import jwt
import json

from datetime import datetime

JWT_SECRET = os.environ.get('JWT_SECRET', 'SECRET')
LAMBDA_ENV = os.environ.get('LAMBDA_ENV', 'development')

def generate_policy(principal_id, effect, resource, context):
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
      'principalId': principal_id,
    }

    if (effect is not None and resource is not None):
        stmt = {
            'Action': 'execute-api:Invoke',
            'Effect': effect,
            'Resource': resource,
        }
        policy_document = {
            'Version': '2012-10-17',
            'Statement': [stmt],
        }
        auth_response.update({
            'policyDocument': policy_document,
        })
    auth_response.update({
        'context': {
            "username": context['username'],
            "email": context['email']
        }
    })

    return auth_response


def handler(event=None, context=None, callback=None):
  print('event', event)
  print('context', context)
  print('callback', callback)

  resource = event['methodArn']
  print('resource', resource)

  token = event['authorizationToken']
  print('token', token)

  try:
      token_decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
      print('token_decoded', token_decoded)
  except Exception as e:
      print(e)
      # return callback("Unauthorized")
      raise e

  if ('username' not in token_decoded or 'email' not in token_decoded):
      # return callback("Unauthorized")
      raise Exception("Unauthorized")

  now = datetime.now()
  timestamp = datetime.timestamp(now)

  if (token_decoded['exp'] < timestamp):
      print('Token has expired')
      # return callback("Unauthorized")
      raise Exception("Unauthorized")

  policy = generate_policy(token_decoded['email'], 'Allow', resource, token_decoded)
  print('policy', policy)

  return policy


if LAMBDA_ENV == 'development':
    event = {
        "type": "TOKEN",
        "authorizationToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Imp1bGlvc2NoZWlkdCIsImVtYWlsIjoianVsaW9zY2hlaWR0QG1haWwuY29tIiwiaWF0IjoxNjUyNDExOTM2LjA1NzM3NiwiZXhwIjoxNjUyNDE1NTM2LjA1NzM3Nn0.CqU6_qUIrPzPOwl3C8_ZKTEAWGQdIK41vxMPC71WRf8",
        "methodArn": "arn:aws:execute-api:us-east-1:XXXXXXXXXXXX:abc1234abc/*/GET/"
    }
    def callable_fn_mock(response=None, value=None): pass
    handler(event, None, callable_fn_mock)

# LAMBDA_ENV=development python3 index.py
