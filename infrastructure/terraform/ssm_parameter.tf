resource "aws_ssm_parameter" "lambda_jwt_secret" {
  name   = "/lambda/${var.env}/jwt-secret"
  type   = "SecureString"
  value  = var.lambda_jwt_secret
  key_id = aws_kms_key.customer_key.key_id
  tags = merge(var.tags, {
    "Name" = "lambda-jwt-secret-${var.env}"
  })
  depends_on = [
    aws_kms_key.customer_key,
  ]
}
