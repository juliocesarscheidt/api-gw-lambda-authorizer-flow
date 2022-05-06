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
  rest_api_id        = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id        = aws_api_gateway_rest_api.api_gw_rest_api.root_resource_id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {}
}

resource "aws_api_gateway_integration" "api_gw_integration_root" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_root.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_root.http_method
  uri                     = "http://${aws_lb.elb_load_balancer.dns_name}/"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  request_parameters      = null
  request_templates       = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  depends_on = [
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
  rest_api_id        = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id        = aws_api_gateway_resource.api_gw_resource_healthcheck.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {}
}

resource "aws_api_gateway_integration" "api_gw_integration_healthcheck" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_method.api_gw_method_healthcheck.resource_id
  http_method             = aws_api_gateway_method.api_gw_method_healthcheck.http_method
  uri                     = "http://${aws_lb.elb_load_balancer.dns_name}/healthcheck"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  request_parameters      = null
  request_templates       = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  depends_on = [
    aws_lb.elb_load_balancer,
    aws_api_gateway_vpc_link.vpc_link,
  ]
}

resource "aws_api_gateway_deployment" "api_gw_deploy" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  stage_name  = "dev"
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api_gw_resource_healthcheck.id,
      aws_api_gateway_method.api_gw_method_root.id,
      aws_api_gateway_method.api_gw_method_healthcheck.id,
      aws_api_gateway_integration.api_gw_integration_root.id,
      aws_api_gateway_integration.api_gw_integration_healthcheck.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_resource.api_gw_resource_healthcheck,
    aws_api_gateway_method.api_gw_method_root,
    aws_api_gateway_method.api_gw_method_healthcheck,
    aws_api_gateway_integration.api_gw_integration_root,
    aws_api_gateway_integration.api_gw_integration_healthcheck,
    aws_api_gateway_rest_api.api_gw_rest_api
  ]
}
