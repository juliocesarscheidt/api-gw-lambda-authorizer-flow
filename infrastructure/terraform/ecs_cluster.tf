resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.ecs_cluster_name}-${var.env}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cluster_capacity_provider.name]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_cluster_capacity_provider.name
  }
  depends_on = [
    aws_ecs_cluster.ecs_cluster,
    aws_ecs_capacity_provider.ecs_cluster_capacity_provider,
  ]
}

resource "aws_ecs_capacity_provider" "ecs_cluster_capacity_provider" {
  name = "default-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ec2_asg.arn
  }
  depends_on = [
    aws_autoscaling_group.ec2_asg,
  ]
}
