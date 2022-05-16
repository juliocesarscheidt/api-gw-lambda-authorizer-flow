output "elb_dns_name" {
  value = aws_lb.elb_load_balancer.dns_name
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.api_gw_deploy.invoke_url
}

output "api_gateway_api_key_value" {
  value = var.api_gw_usage_plan_enabled ? aws_api_gateway_api_key.api_gw_api_key.0.value : ""
}
