resource "aws_autoscaling_group" "ec2_asg" {
  name                      = "ec2-asg-default-ecs-ami-${var.env}"
  capacity_rebalance        = true
  desired_capacity          = 1
  max_size                  = length(var.subnet_ids)
  min_size                  = 0
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
    value               = "ec2-asg-default-ecs-ami-${var.env}"
    propagate_at_launch = false
  }
  depends_on = [
    aws_lb_target_group.elb_target_group,
    aws_launch_template.ec2_launch_template,
  ]
}
