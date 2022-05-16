resource "aws_api_gateway_rest_api" "api_gw_rest_api" {
  name        = "api-gw-rest-api-${var.env}"
  description = "API Rest"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = merge(var.tags, {
    "Name" = "api-gw-rest-api-${var.env}"
  })
}

# resource, method and integration - root
resource "aws_api_gateway_method" "api_gw_method_root" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_rest_api.api_gw_rest_api.root_resource_id
  # api_key_required   = true
  http_method        = "GET"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.api_gateway_authorizer.id
  request_parameters = {}
  depends_on = [
    aws_api_gateway_authorizer.api_gateway_authorizer,
  ]
}

resource "aws_api_gateway_integration" "api_gw_integration_root" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_root.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_root.http_method
  uri                     = "http://${aws_lb.elb_load_balancer.dns_name}:${var.ecs_application_port}/"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  request_parameters      = null
  request_templates       = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_method.api_gw_method_root,
    aws_lb.elb_load_balancer,
    aws_api_gateway_vpc_link.vpc_link,
  ]
}

# resource, method and integration - healthcheck
resource "aws_api_gateway_resource" "api_gw_resource_healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  parent_id   = aws_api_gateway_method.api_gw_method_root.resource_id
  path_part   = "healthcheck"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api
  ]
}

resource "aws_api_gateway_method" "api_gw_method_healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_resource.api_gw_resource_healthcheck.id
  # api_key_required   = true
  http_method        = "GET"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.api_gateway_authorizer.id
  request_parameters = {}
  depends_on = [
    aws_api_gateway_authorizer.api_gateway_authorizer,
  ]
}

resource "aws_api_gateway_integration" "api_gw_integration_healthcheck" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_healthcheck.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_healthcheck.http_method
  uri                     = "http://${aws_lb.elb_load_balancer.dns_name}:${var.ecs_application_port}/healthcheck"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  request_parameters      = null
  request_templates       = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_method.api_gw_method_healthcheck,
    aws_lb.elb_load_balancer,
    aws_api_gateway_vpc_link.vpc_link,
  ]
}

# resource, method and integration - signin
resource "aws_api_gateway_resource" "api_gw_resource_signin" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  parent_id   = aws_api_gateway_method.api_gw_method_root.resource_id
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

# deployment
resource "aws_api_gateway_deployment" "api_gw_deploy" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.api_gw_method_root.id,
      aws_api_gateway_integration.api_gw_integration_root.id,
      aws_api_gateway_method.api_gw_method_healthcheck.id,
      aws_api_gateway_integration.api_gw_integration_healthcheck.id,
      aws_api_gateway_method.api_gw_method_signin.id,
      aws_api_gateway_integration.api_gw_integration_signin.id,
      aws_api_gateway_method.api_gw_method_signup.id,
      aws_api_gateway_integration.api_gw_integration_signup.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_method.api_gw_method_root,
    aws_api_gateway_integration.api_gw_integration_root,
    aws_api_gateway_method.api_gw_method_healthcheck,
    aws_api_gateway_integration.api_gw_integration_healthcheck,
    aws_api_gateway_method.api_gw_method_signin,
    aws_api_gateway_integration.api_gw_integration_signin,
    aws_api_gateway_method.api_gw_method_signup,
    aws_api_gateway_integration.api_gw_integration_signup,
  ]
}
