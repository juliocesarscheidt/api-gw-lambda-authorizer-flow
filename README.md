# API Gateway with VPC Link to expose internal services, using Lambda Authorizer

The API Gateway uses a Lambda Authorizer to authorize requests to the services running on ECS, there is also another Lambda responsible for signing up and signing in users, generating and JWT token to be used then with the Lambda Authorizer.

The containers on ECS are reached through a network load balancer pointing to the EC2s, and there is VPC Link in front of the network balancer, then the API Gateway uses the HTTP Proxy with VPC Link integration to reach protected endpoints on ECS and Lambda with Proxy integration to reach authentication endpoints.

> Architecture

![Architecture](./architecture/api-gw-lambda-authorizer.drawio.svg)

> Auth Flow

![Flow](./architecture/api-gw-lambda-authorizer-flow.drawio.svg)

## Deploy with Terraform

```bash
# login into the ECR, build the image, creates the repository (if doesn't exist) and pushes the image to the repository
make push-image

# plan and apply the plan
make apply
```

## Usage

```bash
cd infrastructure/terraform/

export API_GW_ENDPOINT="$(terraform output -raw api_gateway_invoke_url)authorizer"

curl --silent -X GET "${API_GW_ENDPOINT}/healthcheck"
# {"message":"Unauthorized"}

# SignUp - creates the user
curl --silent -X GET "${API_GW_ENDPOINT}/signup" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "username": "julioscheidt",  "password": "SOME_PASSWORD"}'

# SignIn - get token
curl --silent -X GET "${API_GW_ENDPOINT}/signin" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "password": "SOME_PASSWORD"}'
# {"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Imp1bGlvc2NoZWlkdEBtYWlsLmNvbSIsInVzZXJuYW1lIjoianVsaW9zY2hlaWR0IiwicGFzc3dvcmQiOiJQQVNTV09SRCIsImlhdCI6MTY1MjY1MTk3NC44NTMwMzgsImV4cCI6MTY1MjY1NTU3NC44NTMwMzh9.mLrE--pXerZF2wix7O7GVmX7OaWXduk1_vmsdK6bAGc"}

curl --silent -X GET "${API_GW_ENDPOINT}/healthcheck" -H "Authorization: INVALID"
# {"Message":"User is not authorized to access this resource with an explicit deny"}

export TOKEN=$(curl --silent -X GET "${API_GW_ENDPOINT}/signin" -H 'Content-type: Application/json' -X POST --data-raw '{"email": "julioscheidt@mail.com", "password": "SOME_PASSWORD"}' | jq -r '.token')

curl --silent -X GET "${API_GW_ENDPOINT}/healthcheck" -H "Authorization: ${TOKEN}"
# {"message":"OK","status":"success"}
```
