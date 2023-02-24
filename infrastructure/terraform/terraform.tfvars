# this is a sample file
aws_region = "us-east-1"
env        = "development"
vpc_id     = ""
subnet_ids = []
# Lambda
lambda_authorizer_name    = "lambda-authorizer"
lambda_authorizer_version = "0.0.1"
lambda_authorizer_environment_config = {
  ENV = "development"
}
lambda_authenticator_name    = "lambda-authenticator"
lambda_authenticator_version = "0.0.1"
lambda_authenticator_environment_config = {
  ENV = "development"
}
lambda_jwt_secret = "SECRET"
docker_registry   = "000000000000.dkr.ecr.us-east-1.amazonaws.com"
# ECS
ecs_application_name                = "go-micro-api"
ecs_application_version             = "v1.0.0"
ecs_application_registry_repository = "docker.io/juliocesarmidia"
ecs_application_port                = 9000
ecs_application_environment = [
  { "name" : "API_PORT", "value" : "9000" },
  { "name" : "MESSAGE", "value" : "API v1" },
]
# miscellaneous
tags = {
  "ENVIRONMENT" = "development"
}
