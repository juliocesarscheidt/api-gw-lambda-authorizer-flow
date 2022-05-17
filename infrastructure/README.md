## Deploy IaC

In order to deploy, run the following commands:

```bash
export ENV="development"
# aws settings
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"
# S3 bucket for terraform backend
export AWS_BACKEND_BUCKET="backend-bucket-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n1)"
export AWS_BACKEND_ACCESS_KEY_ID="$AWS_BACKEND_ACCESS_KEY_ID"
export AWS_BACKEND_SECRET_ACCESS_KEY="$AWS_BACKEND_SECRET_ACCESS_KEY"
export AWS_BACKEND_REGION="$AWS_BACKEND_REGION"
# application settings
export AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r '.Account')
export DOCKER_REGISTRY="${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
# Lambda variables
export LAMBDA_AUTHORIZER_NAME="lambda-authorizer"
export LAMBDA_AUTHORIZER_VERSION="0.0.1"
export LAMBDA_AUTHENTICATOR_NAME="lambda-authenticator"
export LAMBDA_AUTHENTICATOR_VERSION="0.0.1"

cd terraform/

# login into the ECR, build the image, creates the repository (if doesn't exist) and pushes the image to the repository
make push-image

# create the backend bucket on S3 (if doesn't exist, this could take a few minutes), initializes the terraform, create the workspaces, validate and do the plan
make init

# apply the previous plan
make apply
```
