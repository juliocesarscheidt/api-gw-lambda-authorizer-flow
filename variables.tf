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

variable "ssh_key_name" {
  type        = string
  description = "SSH key name for accessing instances"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ { BusinessUnit : ABC })"
  default     = {}
}
