#!/usr/bin/make

SHELL=/bin/bash

ENV?=development

LAMBDA_NAME?=lambda-authorizer
LAMBDA_VERSION?=0.0.1

AWS_USERNAME?="AWS"
AWS_REGION?=us-east-1

DOCKER_REGISTRY_REGION?=us-east-1
DOCKER_REGISTRY?=000000000000.dkr.ecr.$(DOCKER_REGISTRY_REGION).amazonaws.com

docker-login:
	docker login --username $(AWS_USERNAME) \
		--password $$(aws ecr get-login-password --region $(DOCKER_REGISTRY_REGION)) \
		$(DOCKER_REGISTRY)

create-docker-repo: docker-login
	aws ecr describe-repositories --repository-names $(LAMBDA_NAME)-$(ENV) \
		--region $(DOCKER_REGISTRY_REGION) || aws ecr create-repository \
			--repository-name $(LAMBDA_NAME)-$(ENV) --region $(DOCKER_REGISTRY_REGION) \
			--image-scanning-configuration scanOnPush=false --image-tag-mutability MUTABLE

build-image:
	docker image build --tag $(DOCKER_REGISTRY)/$(LAMBDA_NAME)-$(ENV):$(LAMBDA_VERSION) ./lambda-authorizer

push-image: create-docker-repo build-image
	docker image push $(DOCKER_REGISTRY)/$(LAMBDA_NAME)-$(ENV):$(LAMBDA_VERSION)

fmt:
	terraform fmt -write=true -recursive

validate:
	terraform validate

init:
	terraform init -reconfigure \
		-backend=true \
		-upgrade=true

plan: validate
	terraform plan \
		-input=false \
		-out=tfplan \
		-var-file=terraform.tfvars \
		-var docker_registry=$(DOCKER_REGISTRY) \
		-var lambda_name=$(LAMBDA_NAME) \
		-var lambda_version=$(LAMBDA_VERSION) \
		-var aws_region=$(AWS_REGION)

apply: plan
	terraform apply tfplan
	make output

output:
	terraform output
