#!/usr/bin/make

SHELL=/bin/bash
ENV?=development
# Lambda variables
LAMBDA_AUTHORIZER_NAME?=lambda-authorizer
LAMBDA_AUTHORIZER_VERSION?=0.0.1
LAMBDA_AUTHENTICATOR_NAME?=lambda-authenticator
LAMBDA_AUTHENTICATOR_VERSION?=0.0.1
# AWS variables
AWS_USERNAME?=AWS
AWS_REGION?=us-east-1
# Docker registry variables
DOCKER_REGISTRY_REGION?=us-east-1
DOCKER_REGISTRY?=000000000000.dkr.ecr.$(DOCKER_REGISTRY_REGION).amazonaws.com

docker-login:
	docker login --username $(AWS_USERNAME) \
		--password $$(aws ecr get-login-password --region $(DOCKER_REGISTRY_REGION)) \
		$(DOCKER_REGISTRY)

create-docker-repo: docker-login
	aws ecr describe-repositories --repository-names $(LAMBDA_AUTHORIZER_NAME)-$(ENV) \
		--region $(DOCKER_REGISTRY_REGION) || aws ecr create-repository \
			--repository-name $(LAMBDA_AUTHORIZER_NAME)-$(ENV) --region $(DOCKER_REGISTRY_REGION) \
			--image-scanning-configuration scanOnPush=false --image-tag-mutability MUTABLE
	aws ecr describe-repositories --repository-names $(LAMBDA_AUTHENTICATOR_NAME)-$(ENV) \
		--region $(DOCKER_REGISTRY_REGION) || aws ecr create-repository \
			--repository-name $(LAMBDA_AUTHENTICATOR_NAME)-$(ENV) --region $(DOCKER_REGISTRY_REGION) \
			--image-scanning-configuration scanOnPush=false --image-tag-mutability MUTABLE

build-image:
	docker image build --tag $(DOCKER_REGISTRY)/$(LAMBDA_AUTHORIZER_NAME)-$(ENV):$(LAMBDA_AUTHORIZER_VERSION) ./lambda-authorizer
	docker image build --tag $(DOCKER_REGISTRY)/$(LAMBDA_AUTHENTICATOR_NAME)-$(ENV):$(LAMBDA_AUTHENTICATOR_VERSION) ./lambda-authenticator

push-image: create-docker-repo build-image
	docker image push $(DOCKER_REGISTRY)/$(LAMBDA_AUTHORIZER_NAME)-$(ENV):$(LAMBDA_AUTHORIZER_VERSION)
	docker image push $(DOCKER_REGISTRY)/$(LAMBDA_AUTHENTICATOR_NAME)-$(ENV):$(LAMBDA_AUTHENTICATOR_VERSION)

fmt:
	cd $$(pwd)/infrastructure/terraform && terraform fmt -write=true -recursive

validate:
	cd $$(pwd)/infrastructure/terraform && terraform validate

lint:
	cd $$(pwd)/infrastructure/terraform && docker container run --rm -t \
		--name tflint \
		--env TFLINT_LOG=debug \
		-v $$(pwd):/data \
		ghcr.io/terraform-linters/tflint

init:
	cd $$(pwd)/infrastructure/terraform && terraform init -reconfigure \
		-backend=true \
		-upgrade=true

plan: validate lint
	cd $$(pwd)/infrastructure/terraform && terraform plan \
		-input=false \
		-out=tfplan \
		-var-file=terraform.tfvars \
		-var docker_registry=$(DOCKER_REGISTRY) \
		-var lambda_authorizer_name=$(LAMBDA_AUTHORIZER_NAME) \
		-var lambda_authorizer_version=$(LAMBDA_AUTHORIZER_VERSION) \
		-var lambda_authenticator_name=$(LAMBDA_AUTHENTICATOR_NAME) \
		-var lambda_authenticator_version=$(LAMBDA_AUTHENTICATOR_VERSION) \
		-var aws_region=$(AWS_REGION)

apply: plan
	cd $$(pwd)/infrastructure/terraform && terraform apply tfplan
	make output

output:
	cd $$(pwd)/infrastructure/terraform && terraform output

destroy:
	cd $$(pwd)/infrastructure/terraform && terraform destroy -auto-approve -input=false
