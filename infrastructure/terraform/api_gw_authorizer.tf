resource "aws_api_gateway_stage" "api_gw_authorizer_stage" {
  deployment_id = aws_api_gateway_deployment.api_gw_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id
  stage_name    = "authorizer"
  depends_on = [
    aws_api_gateway_deployment.api_gw_deploy,
    aws_api_gateway_rest_api.api_gw_rest_api,
  ]
}

resource "aws_api_gateway_authorizer" "api_gateway_authorizer" {
  name                             = "api-gateway-authorizer-${var.env}"
  authorizer_result_ttl_in_seconds = 0
  rest_api_id                      = aws_api_gateway_rest_api.api_gw_rest_api.id
  authorizer_uri                   = aws_lambda_function.lambda_function_authorizer.invoke_arn
  authorizer_credentials           = aws_iam_role.lambda_iam_invocation_api_gw_role.arn
  type                             = "TOKEN"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_lambda_function.lambda_function_authorizer,
    aws_iam_role.lambda_iam_invocation_api_gw_role,
  ]
}
