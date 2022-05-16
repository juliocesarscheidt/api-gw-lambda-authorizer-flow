import os
import sys
import jwt
import json

from datetime import datetime

JWT_SECRET = os.environ.get('JWT_SECRET', 'SECRET')
ENV = os.environ.get('ENV', 'local')

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
    if context is not None and 'username' in context and 'email' in context:
      auth_response.update({
          'context': {
              "username": context['username'],
              "email": context['email']
          }
      })

    print('auth_response', auth_response)
    return auth_response


def handler(event=None, context=None, callback=None):
  print('event', event)
  print('context', context)
  print('callback', callback)

  resource = event['methodArn']
  print('resource', resource)

  token = event['authorizationToken']
  print('token', token)

  if token is None or token == '': return generate_policy('anonymous', 'Deny', resource)

  try:
      token_decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
      print('token_decoded', token_decoded)
  except Exception as e:
      print(e)
      return generate_policy('anonymous', 'Deny', resource)

  if ('username' not in token_decoded or 'email' not in token_decoded):
      print('Invalid username or email')
      return generate_policy('anonymous', 'Deny', resource)

  principal_id = token_decoded['email']

  now = datetime.now()
  timestamp = datetime.timestamp(now)

  if ('exp' not in token_decoded or token_decoded['exp'] < timestamp):
      print('Token invalid or has expired')
      return generate_policy(principal_id, 'Deny', resource, token_decoded)

  return generate_policy(principal_id, 'Allow', resource, token_decoded)


if ENV == 'local':
    event = {
        "type": "TOKEN",
        "authorizationToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Imp1bGlvc2NoZWlkdEBtYWlsLmNvbSIsInVzZXJuYW1lIjoianVsaW9zY2hlaWR0IiwiaWF0IjoxNjUyNjYzMzg4LjYyNTI5OCwiZXhwIjoxNjUyNjY2OTg4LjYyNTI5OH0.qjm_OJ5ltdMjaGtap69x25YiNjZO4O-HKIQ2luuIso8",
        "methodArn": "arn:aws:execute-api:us-east-1:XXXXXXXXXXXX:abc1234abc/*/GET/"
    }
    def callable_fn_mock(response=None, value=None): pass
    handler(event, None, callable_fn_mock)
