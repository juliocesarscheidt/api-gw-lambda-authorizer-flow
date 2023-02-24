resource "tls_private_key" "ec2_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-key-pair-ecs-${var.env}"
  public_key = tls_private_key.ec2_rsa_key.public_key_openssh
}
