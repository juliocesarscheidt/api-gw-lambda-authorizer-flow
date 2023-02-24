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

# deployment
resource "aws_api_gateway_deployment" "api_gw_deploy" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.api_gw_method_root.id,
      aws_api_gateway_integration.api_gw_integration_root.id,
      aws_api_gateway_method.api_gw_method_message.id,
      aws_api_gateway_integration.api_gw_integration_message.id,
      aws_api_gateway_method.api_gw_method_configuration.id,
      aws_api_gateway_integration.api_gw_integration_configuration.id,
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
    aws_api_gateway_method.api_gw_method_message,
    aws_api_gateway_integration.api_gw_integration_message,
    aws_api_gateway_method.api_gw_method_configuration,
    aws_api_gateway_integration.api_gw_integration_configuration,
    aws_api_gateway_method.api_gw_method_signin,
    aws_api_gateway_integration.api_gw_integration_signin,
    aws_api_gateway_method.api_gw_method_signup,
    aws_api_gateway_integration.api_gw_integration_signup,
  ]
}
