## APIs Usage

```bash
cd ../infrastructure/terraform/

export API_GW_ENDPOINT="$(terraform output -raw api_gateway_invoke_url)authorizer"

curl --silent -X GET "${API_GW_ENDPOINT}/healthcheck"
# {"message":"Unauthorized"}

# SignUp - creates the user
curl --silent -X GET "${API_GW_ENDPOINT}/signup" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "username": "julioscheidt", "password": "SOME_PASSWORD"}'

# SignIn - get token
curl --silent -X GET "${API_GW_ENDPOINT}/signin" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "password": "SOME_PASSWORD"}'
# {"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Imp1bGlvc2NoZWlkdEBtYWlsLmNvbSIsInVzZXJuYW1lIjoianVsaW9zY2hlaWR0IiwiaWF0IjoxNjUyNzU2NDY0LjcyMzgyNSwiZXhwIjoxNjUyNzYwMDY0LjcyMzgyNX0.sJyv-RXS_9b60UMAysvm0XEYXTmtC2nlp9n8HE-YFFA"}

curl --silent -X GET "${API_GW_ENDPOINT}/healthcheck" -H "Authorization: INVALID"
# {"Message":"User is not authorized to access this resource with an explicit deny"}

export TOKEN=$(curl --silent -X GET "${API_GW_ENDPOINT}/signin" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "password": "SOME_PASSWORD"}' | jq -r '.token')

curl --silent -X GET "${API_GW_ENDPOINT}/healthcheck" -H "Authorization: ${TOKEN}"
# {"message":"OK","status":"success"}
```
