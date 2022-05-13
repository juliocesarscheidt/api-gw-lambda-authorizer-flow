output "elb_dns_name" {
  value = aws_lb.elb_load_balancer.dns_name
}

output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_deployment.api_gw_deploy.invoke_url}${var.api_gw_stage_name}"
}
