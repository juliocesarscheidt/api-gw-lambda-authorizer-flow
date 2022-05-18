############################### Lambda Authorizer ###############################
resource "aws_cloudwatch_log_group" "lambda_log_group_authorizer" {
  name              = "/aws/lambda/${var.lambda_authorizer_name}-${var.env}"
  retention_in_days = 1
}

resource "aws_lambda_alias" "lambda_function_alias_v1_authorizer" {
  name             = "v1"
  function_name    = aws_lambda_function.lambda_function_authorizer.function_name
  function_version = "$LATEST"
  depends_on = [
    aws_lambda_function.lambda_function_authorizer,
  ]
}

resource "aws_lambda_function" "lambda_function_authorizer" {
  function_name = "${var.lambda_authorizer_name}-${var.env}"
  image_uri     = "${var.docker_registry}/${var.lambda_authorizer_name}-${var.env}:${var.lambda_authorizer_version}"
  package_type  = "Image"
  role          = aws_iam_role.lambda_iam_role.arn
  timeout       = 30 # 30 seconds
  memory_size   = 512
  publish       = true
  environment {
    variables = var.lambda_authorizer_environment_config
  }
  tags = merge(var.tags, {
    "Name" = "${var.lambda_authorizer_name}-${var.env}"
  })
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_ssm_parameter.lambda_jwt_secret,
  ]
}

############################### Lambda Authenticator ###############################
resource "aws_cloudwatch_log_group" "lambda_log_group_authenticator" {
  name              = "/aws/lambda/${var.lambda_authenticator_name}-${var.env}"
  retention_in_days = 1
}

resource "aws_lambda_alias" "lambda_function_alias_v1_authenticator" {
  name             = "v1"
  function_name    = aws_lambda_function.lambda_function_authenticator.function_name
  function_version = "$LATEST"
  depends_on = [
    aws_lambda_function.lambda_function_authenticator,
  ]
}

resource "aws_lambda_function" "lambda_function_authenticator" {
  function_name = "${var.lambda_authenticator_name}-${var.env}"
  image_uri     = "${var.docker_registry}/${var.lambda_authenticator_name}-${var.env}:${var.lambda_authenticator_version}"
  package_type  = "Image"
  role          = aws_iam_role.lambda_iam_role.arn
  timeout       = 30 # 30 seconds
  memory_size   = 512
  publish       = true
  environment {
    variables = var.lambda_authenticator_environment_config
  }
  tags = merge(var.tags, {
    "Name" = "${var.lambda_authenticator_name}-${var.env}"
  })
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_ssm_parameter.lambda_jwt_secret,
  ]
}

# permission for API gateway to invoke Lambda Function
resource "aws_lambda_permission" "invoke_lambda_authenticator_permission" {
  statement_id  = "invoke-lambda-authenticator-permission-${var.env}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_authenticator.function_name
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api_gw_rest_api.execution_arn}/*/*"
  depends_on = [
    aws_lambda_function.lambda_function_authenticator,
    aws_api_gateway_rest_api.api_gw_rest_api
  ]
}
