resource "aws_secretsmanager_secret" "secret_manager_ec2_private_key" {
  name                    = "/aws/ec2/keypair/ec2-launch-template-ecs-${var.env}/private-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_manager_ec2_private_key_version" {
  secret_id     = aws_secretsmanager_secret.secret_manager_ec2_private_key.id
  secret_string = tls_private_key.ec2_rsa_key.private_key_openssh
}

resource "aws_secretsmanager_secret" "secret_manager_ec2_public_key" {
  name                    = "/aws/ec2/keypair/ec2-launch-template-ecs-${var.env}/public-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_manager_ec2_public_key_version" {
  secret_id     = aws_secretsmanager_secret.secret_manager_ec2_public_key.id
  secret_string = tls_private_key.ec2_rsa_key.public_key_openssh
}
