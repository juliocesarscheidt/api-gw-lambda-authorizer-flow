resource "aws_api_gateway_stage" "api_gw_plan_stage" {
  count         = var.api_gw_usage_plan_enabled ? 1 : 0
  deployment_id = aws_api_gateway_deployment.api_gw_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id
  stage_name    = "plan"
  depends_on = [
    aws_api_gateway_deployment.api_gw_deploy,
    aws_api_gateway_rest_api.api_gw_rest_api,
  ]
}

resource "aws_api_gateway_usage_plan" "api_gw_usage_plan" {
  count = var.api_gw_usage_plan_enabled ? 1 : 0
  name  = "${var.api_gw_usage_plan_name}-${var.env}"
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
    stage  = aws_api_gateway_stage.api_gw_plan_stage[0].stage_name
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
    aws_api_gateway_stage.api_gw_plan_stage,
  ]
}

resource "aws_api_gateway_api_key" "api_gw_api_key" {
  count = var.api_gw_usage_plan_enabled ? 1 : 0
  name  = "${var.api_gw_usage_plan_name}-${var.env}-api-key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count         = var.api_gw_usage_plan_enabled ? 1 : 0
  key_id        = aws_api_gateway_api_key.api_gw_api_key[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_gw_usage_plan[0].id
  depends_on = [
    aws_api_gateway_api_key.api_gw_api_key,
    aws_api_gateway_usage_plan.api_gw_usage_plan,
  ]
}

# curl -X GET "$(terraform output -raw api_gateway_invoke_url)plan"
# Forbidden

# curl -X GET "$(terraform output -raw api_gateway_invoke_url)plan" -H "X-Api-Key: $(terraform output -raw api_gateway_api_key_value)"
