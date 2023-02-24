resource "aws_security_group" "ec2_internal_sg" {
  name   = "ec2-internal-sg-${var.env}"
  vpc_id = aws_vpc.vpc_0.id
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
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = var.ecs_application_port
    to_port     = var.ecs_application_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}
