terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "=4.55.0"
    }
    template = {
      source  = "registry.terraform.io/hashicorp/template"
      version = "=2.2.0"
    }
    tls = {
      source  = "registry.terraform.io/hashicorp/tls"
      version = "=4.0.4"
    }
  }
}
