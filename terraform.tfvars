aws_region = "us-east-1"
env        = "dev"
vpc_id     = ""
subnet_ids = [""]
# ECS
ecs_application_name                = "http-simple-api"
ecs_application_version             = "v2.0.0"
ecs_application_registry_repository = "docker.io/juliocesarmidia"
ecs_application_port                = 5000
ecs_application_environment = [
  { "name" : "API_PORT", "value" : "5000" },
]
ecs_application_execution_role_arn = "arn:aws:iam::000000000000:role/AmazonECSTaskExecutionRole"
ecs_application_task_role_arn      = ""
# EC2
ec2_ssh_key_name = "key_aws"
# API GW
api_gw_stage_name = "dev"
# miscellaneous
tags = {
  "ENVIRONMENT" = "dev"
}
