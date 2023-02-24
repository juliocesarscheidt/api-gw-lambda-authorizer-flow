#!/usr/bin/make

# general variables
ENV?=development
PLAN_FILE?=tfplan
# Lambda variables
LAMBDA_AUTHORIZER_NAME?=lambda-authorizer
LAMBDA_AUTHORIZER_VERSION?=0.0.1
LAMBDA_AUTHENTICATOR_NAME?=lambda-authenticator
LAMBDA_AUTHENTICATOR_VERSION?=0.0.1
# AWS variables
AWS_ACCESS_KEY_ID?=
AWS_SECRET_ACCESS_KEY?=
AWS_DEFAULT_REGION?=us-east-1
# Terraform backend variables
AWS_BACKEND_BUCKET?=
AWS_BACKEND_ACCESS_KEY_ID?=
AWS_BACKEND_SECRET_ACCESS_KEY?=
AWS_BACKEND_REGION?=us-east-1
# docker variables
DOCKER_REGISTRY?=000000000000.dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com

docker-login:
	aws ecr get-login-password --region $(AWS_DEFAULT_REGION) | \
		docker login --username AWS $(DOCKER_REGISTRY) --password-stdin

create-ecr-repo:
	aws ecr describe-repositories --repository-names $(LAMBDA_AUTHORIZER_NAME)-$(ENV) \
		--region $(AWS_DEFAULT_REGION) || aws ecr create-repository \
			--repository-name $(LAMBDA_AUTHORIZER_NAME)-$(ENV) --region $(AWS_DEFAULT_REGION) \
			--image-scanning-configuration scanOnPush=false --image-tag-mutability MUTABLE
	aws ecr describe-repositories --repository-names $(LAMBDA_AUTHENTICATOR_NAME)-$(ENV) \
		--region $(AWS_DEFAULT_REGION) || aws ecr create-repository \
			--repository-name $(LAMBDA_AUTHENTICATOR_NAME)-$(ENV) --region $(AWS_DEFAULT_REGION) \
			--image-scanning-configuration scanOnPush=false --image-tag-mutability MUTABLE

build-image:
	docker image build --tag $(DOCKER_REGISTRY)/$(LAMBDA_AUTHORIZER_NAME)-$(ENV):$(LAMBDA_AUTHORIZER_VERSION) ../../lambda-authorizer
	docker image build --tag $(DOCKER_REGISTRY)/$(LAMBDA_AUTHENTICATOR_NAME)-$(ENV):$(LAMBDA_AUTHENTICATOR_VERSION) ../../lambda-authenticator

push-image: docker-login build-image create-ecr-repo
	docker image push $(DOCKER_REGISTRY)/$(LAMBDA_AUTHORIZER_NAME)-$(ENV):$(LAMBDA_AUTHORIZER_VERSION)
	docker image push $(DOCKER_REGISTRY)/$(LAMBDA_AUTHENTICATOR_NAME)-$(ENV):$(LAMBDA_AUTHENTICATOR_VERSION)

create-backend-bucket:
	-@aws s3 ls s3://$(AWS_BACKEND_BUCKET) --region $(AWS_BACKEND_REGION) 2> /dev/null || \
		aws s3api create-bucket --bucket $(AWS_BACKEND_BUCKET) --region $(AWS_BACKEND_REGION) --acl private

create-workspace:
	-@terraform workspace new development 2> /dev/null
	-@terraform workspace new production 2> /dev/null
	terraform workspace select $(ENV)

init: create-backend-bucket
	terraform init -upgrade=true \
		-backend-config="bucket=$(AWS_BACKEND_BUCKET)" \
		-backend-config="key=state.tfstate" \
		-backend-config="region=$(AWS_BACKEND_REGION)" \
		-backend-config="workspace_key_prefix=terraform/api-gw-lambda-authorizer" \
		-backend-config="access_key=$(AWS_BACKEND_ACCESS_KEY_ID)" \
		-backend-config="secret_key=$(AWS_BACKEND_SECRET_ACCESS_KEY)" \
		-backend-config="encrypt=true"
	make create-workspace
	make plan

fmt:
	terraform fmt -write=true -recursive

validate:
	terraform validate

lint:
	docker container run --rm -t \
		--name tflint \
		--env TFLINT_LOG=debug \
		-v $$(pwd):/data \
		ghcr.io/terraform-linters/tflint

refresh:
	terraform refresh	-var-file=$(ENV).tfvars

plan: validate lint
	terraform plan \
		-out=$(PLAN_FILE) \
		-var-file=$(ENV).tfvars \
		-var aws_region="$(AWS_DEFAULT_REGION)" \
		-var docker_registry="$(DOCKER_REGISTRY)" \
		-var lambda_authorizer_name=$(LAMBDA_AUTHORIZER_NAME) \
		-var lambda_authorizer_version=$(LAMBDA_AUTHORIZER_VERSION) \
		-var lambda_authenticator_name=$(LAMBDA_AUTHENTICATOR_NAME) \
		-var lambda_authenticator_version=$(LAMBDA_AUTHENTICATOR_VERSION) \
		-input=false

apply:
	terraform apply $(PLAN_FILE)
	@echo "API GW on $$(terraform output -raw api_gateway_invoke_url)"

output:
	terraform output

destroy:
	terraform destroy \
		-var-file=$(ENV).tfvars \
		-auto-approve
