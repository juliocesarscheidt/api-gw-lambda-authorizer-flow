resource "aws_cloudwatch_log_group" "lambda_log_group_api" {
  name              = "/aws/lambda/${var.lambda_name}-${var.env}"
  retention_in_days = 1
}

resource "aws_lambda_alias" "lambda_function_alias_v1" {
  name             = "v1"
  function_name    = aws_lambda_function.lambda_function.function_name
  function_version = "$LATEST"
  depends_on = [
    aws_lambda_function.lambda_function,
  ]
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.lambda_name}-${var.env}"
  image_uri     = "${var.docker_registry}/${var.lambda_name}-${var.env}:${var.lambda_version}"
  package_type  = "Image"
  role          = aws_iam_role.lambda_iam_role.arn
  timeout       = 30 # 30 seconds
  memory_size   = 512
  publish       = true
  environment {
    variables = var.lambda_environment_config
  }
  depends_on = [
    aws_iam_role.lambda_iam_role,
  ]
  tags = merge(var.tags, {
    "Name" = "${var.lambda_name}-${var.env}"
  })
}
