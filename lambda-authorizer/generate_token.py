#!/usr/bin/env python3

import os
import sys
import jwt
import json

from datetime import datetime

args = sys.argv[1:]
if len(args) <= 0 or str(args[0]).strip() == "":
  print('[ERROR] Missing payload parameter')
  sys.exit(1)

JWT_SECRET = os.environ.get('JWT_SECRET', 'SECRET')

def generate_token(payload: dict) -> str:
    now = datetime.now()
    timestamp = datetime.timestamp(now)
    payload.update({
      'iat': timestamp,
      'exp': timestamp + (60*60*1) # plus 1 hour
    })
    # print(payload)
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")

if __name__ in '__main__':
    payload = json.loads(args[0])
    token = generate_token(payload)
    print(token)

# export TOKEN=$(./generate_token.py '{"username": "julioscheidt", "email": "julioscheidt@mail.com"}')
