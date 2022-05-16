aws_region = "us-east-1"
env        = "development"
vpc_id     = ""
subnet_ids = []
# Lambda
lambda_authorizer_name    = "lambda-authorizer"
lambda_authorizer_version = "0.0.1"
lambda_authorizer_environment_config = {
  JWT_SECRET = "JWT_SECRET"
  ENV        = "development"
}
lambda_authenticator_name    = "lambda-authenticator"
lambda_authenticator_version = "0.0.1"
lambda_authenticator_environment_config = {
  JWT_SECRET = "JWT_SECRET"
  ENV        = "development"
}
docker_registry = "000000000000.dkr.ecr.us-east-1.amazonaws.com"
# ECS
ecs_application_name                = "http-simple-api"
ecs_application_version             = "v2.0.0"
ecs_application_registry_repository = "docker.io/juliocesarmidia"
ecs_application_port                = 5000
ecs_application_environment = [
  { "name" : "API_PORT", "value" : "5000" },
  { "name" : "MESSAGE", "value" : "API v1" },
]
ecs_application_execution_role_arn = "arn:aws:iam::000000000000:role/AmazonECSTaskExecutionRole"
ecs_application_task_role_arn      = ""
# EC2
ec2_ssh_key_name = "key_aws"
# miscellaneous
tags = {
  "ENVIRONMENT" = "development"
}
