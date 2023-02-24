# resource, method and integration - message
resource "aws_api_gateway_resource" "api_gw_resource_message" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  parent_id   = aws_api_gateway_method.api_gw_method_root.resource_id
  path_part   = "message"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api
  ]
}

resource "aws_api_gateway_method" "api_gw_method_message" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_resource.api_gw_resource_message.id
  # api_key_required   = true
  http_method        = "GET"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.api_gateway_authorizer.id
  request_parameters = {}
  depends_on = [
    aws_api_gateway_authorizer.api_gateway_authorizer,
  ]
}

resource "aws_api_gateway_integration" "api_gw_integration_message" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_message.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_message.http_method
  uri                     = "http://${aws_lb.elb_load_balancer.dns_name}:${var.ecs_application_port}/api/v1/message"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  request_parameters      = null
  request_templates       = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_method.api_gw_method_message,
    aws_lb.elb_load_balancer,
    aws_api_gateway_vpc_link.vpc_link,
  ]
}

# resource, method and integration - configuration
resource "aws_api_gateway_resource" "api_gw_resource_configuration" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  parent_id   = aws_api_gateway_method.api_gw_method_root.resource_id
  path_part   = "configuration"
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api
  ]
}

resource "aws_api_gateway_method" "api_gw_method_configuration" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_resource.api_gw_resource_configuration.id
  # api_key_required   = true
  http_method        = "PUT"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.api_gateway_authorizer.id
  request_parameters = {}
  depends_on = [
    aws_api_gateway_authorizer.api_gateway_authorizer,
  ]
}

resource "aws_api_gateway_integration" "api_gw_integration_configuration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_configuration.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_configuration.http_method
  uri                     = "http://${aws_lb.elb_load_balancer.dns_name}:${var.ecs_application_port}/api/v1/configuration"
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"
  request_parameters      = null
  request_templates       = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_method.api_gw_method_configuration,
    aws_lb.elb_load_balancer,
    aws_api_gateway_vpc_link.vpc_link,
  ]
}
