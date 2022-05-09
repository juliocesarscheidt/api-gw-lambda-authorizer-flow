variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "AWS region"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs of subnets"
  default     = []
}


variable "ecs_cluster_name" {
  type        = string
  description = "ECS Cluster Name"
  default     = "ecs-cluster"
}

variable "ecs_application_name" {
  type        = string
  description = "ECS Application Name"
  default     = "http-simple-api"
}

variable "ecs_application_version" {
  type        = string
  description = "ECS Application Version"
  default     = "v2.0.0"
}

variable "ecs_application_registry_repository" {
  type        = string
  description = "ECS Registry Repository"
  default     = ""
}

variable "ecs_application_port" {
  type        = number
  description = "ECS Application Port"
  default     = 5000
}

variable "ecs_application_environment" {
  type        = list(any)
  description = "Config for app container environment"
}

variable "ecs_application_execution_role_arn" {
  type        = string
  description = "ECS Application Execution Role ARN"
  default     = ""
}

variable "ecs_application_task_role_arn" {
  type        = string
  description = "ECS Application Task Role ARN"
  default     = ""
}

variable "ecs_application_deployment_count" {
  type        = map(number)
  description = "ECS Application Deployment Count"
  default = {
    desired = 1
    minimum = 0
    maximum = 100
  }
}


variable "ec2_role_name" {
  type        = string
  description = "Instance Role Name"
  default     = "AmazonEC2Role"
}

variable "ec2_instance_type" {
  type        = string
  description = "Instance Type"
  default     = "t2.micro"
}

variable "ec2_instance_volume_size" {
  type        = number
  description = "Instance Volume Size"
  default     = 30
}

variable "ec2_ami_id" {
  type        = string
  description = "AMI Id"
  default     = "ami-0f260fe26c2826a3d"
}

variable "ec2_ssh_key_name" {
  type        = string
  description = "SSH key name for accessing instances"
}

variable "ec2_asg_deployment_count" {
  type        = map(number)
  description = "EC2 ASG Deployment Count"
  default = {
    desired = 1
    minimum = 0
    maximum = 1
  }
}


variable "api_gw_stage_name" {
  type        = string
  description = "API GW Stage Name"
  default     = "dev"
}

variable "api_gw_usage_plan_name" {
  type        = string
  description = "API GW Usage Plan Name"
  default     = "default-usage-plan"
}

variable "api_gw_usage_plan_quota_settings" {
  type        = map(any)
  description = "API GW Usage Quota Settings"
  default = {
    limit  = 1000
    offset = 0
    period = "MONTH"
  }
}

variable "api_gw_usage_plan_throttle_settings" {
  type        = map(number)
  description = "API GW Usage Throttle Settings"
  default = {
    burst_limit = 5
    rate_limit  = 10
  }
}


variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ { BusinessUnit : ABC })"
  default     = {}
}
