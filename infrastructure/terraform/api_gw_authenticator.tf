# resource, method and integration - signin
resource "aws_api_gateway_resource" "api_gw_resource_signin" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  parent_id   = aws_api_gateway_method.api_gw_method_root.resource_id
  # path endpoint
  path_part   = "signin"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api
  ]
}

resource "aws_api_gateway_method" "api_gw_method_signin" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_resource.api_gw_resource_signin.id
  # api_key_required   = true
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Authorization" = true
  }
  depends_on = [
  ]
}

resource "aws_api_gateway_integration" "api_gw_integration_signin" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_signin.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_signin.http_method
  uri                     = aws_lambda_function.lambda_function_authenticator.invoke_arn
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_method.api_gw_method_signin,
    aws_lambda_function.lambda_function_authenticator,
  ]
}

# resource, method and integration - signup
resource "aws_api_gateway_resource" "api_gw_resource_signup" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  parent_id   = aws_api_gateway_method.api_gw_method_root.resource_id
  # path endpoint
  path_part   = "signup"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api
  ]
}

resource "aws_api_gateway_method" "api_gw_method_signup" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_resource.api_gw_resource_signup.id
  # api_key_required   = true
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Authorization" = true
  }
  depends_on = [
  ]
}

resource "aws_api_gateway_integration" "api_gw_integration_signup" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_signup.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_signup.http_method
  uri                     = aws_lambda_function.lambda_function_authenticator.invoke_arn
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_method.api_gw_method_signup,
    aws_lambda_function.lambda_function_authenticator,
  ]
}
