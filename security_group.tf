data "aws_vpc" "vpc_main" {
  id = var.vpc_id
}

resource "aws_security_group" "ec2_internal_sg" {
  name   = "ec2-internal-sg-${var.env}"
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc_main.cidr_block]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc_main.cidr_block]
  }
}