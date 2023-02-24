## APIs Usage

```bash
cd ../infrastructure/terraform/

export STAGE_NAME="authorizer"
export API_GW_ENDPOINT="$(terraform output -raw api_gateway_invoke_url)${STAGE_NAME}"
echo "${API_GW_ENDPOINT}"

curl --silent --url "${API_GW_ENDPOINT}/message"
# {"message":"Unauthorized"}
curl --silent -X PUT --data '{"message": "Hello World v2"}' --url "${API_GW_ENDPOINT}/configuration"
# {"message":"Unauthorized"}

# SignUp - creates the user
curl --silent --url "${API_GW_ENDPOINT}/signup" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "username": "julioscheidt", "password": "PASSWORD"}'

curl --silent --url "${API_GW_ENDPOINT}/signin" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "password": "NONE"}'
# {"message": "Unauthorized"}

# SignIn - get token
export TOKEN=$(curl --silent --url "${API_GW_ENDPOINT}/signin" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "password": "PASSWORD"}' | jq -r '.token')
echo "${TOKEN}"
# eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Imp1bGlvc2NoZWlkdEBtYWlsLmNvbSIsInVzZXJuYW1lIjoianVsaW9zY2hlaWR0IiwiaWF0IjoxNjc3MjU2NjY2LjUwMjA0MiwiZXhwIjoxNjc3MjYwMjY2LjUwMjA0Mn0.76XIhnClUlrB5tpGibHJBUi2ydTaPTt9WHRqZxbX36U

curl --silent --url "${API_GW_ENDPOINT}/message" -H "Authorization: NONE"
# {"Message":"User is not authorized to access this resource with an explicit deny"}

curl --silent --url "${API_GW_ENDPOINT}/message" -H "Authorization: ${TOKEN}"
# {"data":"API v1","statusCode":200}
curl --silent -X PUT --data '{"message": "Hello World from API GW"}' --url "${API_GW_ENDPOINT}/configuration" -H "Authorization: ${TOKEN}"
# {"data":null,"statusCode":202}
```
