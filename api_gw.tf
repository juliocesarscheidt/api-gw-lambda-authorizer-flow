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

resource "aws_api_gateway_usage_plan" "api_gw_usage_plan" {
  name = "${var.api_gw_usage_plan_name}-${var.env}"
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
    stage  = aws_api_gateway_stage.api_gw_stage.stage_name
  }
  quota_settings {
    limit  = lookup(var.api_gw_usage_plan_quota_settings, "limit")
    offset = lookup(var.api_gw_usage_plan_quota_settings, "offset")
    period = lookup(var.api_gw_usage_plan_quota_settings, "period")
  }
  throttle_settings {
    burst_limit = lookup(var.api_gw_usage_plan_throttle_settings, "burst_limit")
    rate_limit  = lookup(var.api_gw_usage_plan_throttle_settings, "rate_limit")
  }
  tags = merge(var.tags, {
    "Name" = "${var.api_gw_usage_plan_name}-${var.env}"
  })
  depends_on = [
    aws_api_gateway_rest_api.api_gw_rest_api,
    aws_api_gateway_stage.api_gw_stage,
  ]
}

resource "aws_api_gateway_api_key" "api_gw_api_key" {
  name = "${var.api_gw_usage_plan_name}-${var.env}-api-key"
}

output "aws_api_gateway_api_key_value" {
  value       = aws_api_gateway_api_key.api_gw_api_key.value
}

# curl -X GET "$(terraform_0.14.3 output -raw api_gateway_invoke_url)dev/" -H "X-Api-Key: $(terraform_0.14.3 output -raw aws_api_gateway_api_key_value)"

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.api_gw_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_gw_usage_plan.id
  depends_on = [
    aws_api_gateway_api_key.api_gw_api_key,
    aws_api_gateway_usage_plan.api_gw_usage_plan,
  ]
}

# resource, method and integration - root
resource "aws_api_gateway_method" "api_gw_method_root" {
  rest_api_id        = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id        = aws_api_gateway_rest_api.api_gw_rest_api.root_resource_id
  api_key_required   = true
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {}
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
  api_key_required   = true
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {}
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
    aws_lb.elb_load_balancer,
    aws_api_gateway_vpc_link.vpc_link,
  ]
}

resource "aws_api_gateway_stage" "api_gw_stage" {
  deployment_id = aws_api_gateway_deployment.api_gw_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id
  stage_name    = var.api_gw_stage_name
  depends_on = [
    aws_api_gateway_deployment.api_gw_deploy,
    aws_api_gateway_rest_api.api_gw_rest_api,
  ]
}

resource "aws_api_gateway_deployment" "api_gw_deploy" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
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
