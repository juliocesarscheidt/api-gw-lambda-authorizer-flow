resource "aws_autoscaling_group" "ec2_asg" {
  name                      = "ec2-asg-default-ecs-${var.env}"
  capacity_rebalance        = true
  desired_capacity          = lookup(var.ec2_asg_deployment_count, "desired")
  min_size                  = lookup(var.ec2_asg_deployment_count, "minimum_size")
  max_size                  = lookup(var.ec2_asg_deployment_count, "maximum_size")
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.elb_target_group.id]
  vpc_zone_identifier       = var.subnet_ids
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "ec2-asg-default-ecs-${var.env}"
    propagate_at_launch = false
  }
  depends_on = [
    aws_lb_target_group.elb_target_group,
    aws_launch_template.ec2_launch_template,
  ]
}
