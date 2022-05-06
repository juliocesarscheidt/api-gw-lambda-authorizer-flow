resource "aws_lb" "elb_load_balancer" {
  name                       = "elb-internal-${var.env}"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
  tags = merge(var.tags, {
    "Name" = "elb-internal-${var.env}"
  })
}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.elb_load_balancer.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_target_group.arn
  }
  depends_on = [
    aws_lb.elb_load_balancer,
    aws_lb_target_group.elb_target_group,
  ]
}

resource "aws_lb_target_group" "elb_target_group" {
  name        = "target-group-${var.env}"
  target_type = "instance"
  port        = 5000
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    "Name" = "target-group-${var.env}"
  })
}

resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "vpc-link-${var.env}"
  target_arns = [aws_lb.elb_load_balancer.arn]
  tags = merge(var.tags, {
    "Name" = "vpc-link-${var.env}"
  })
  depends_on = [
    aws_lb.elb_load_balancer,
  ]
}
