resource "aws_cloudwatch_log_group" "ecs_task_log_group" {
  retention_in_days = 1
  name              = "/aws/ecs/${var.ecs_application_name}-${var.env}"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.ecs_application_name}-${var.env}-task-definition"
  # role for task execution, which will be used to pull the image, create log stream, start the task, etc
  execution_role_arn = var.ecs_application_execution_role_arn
  # role for task application, to be used by the application itself in execution time, it's optional
  task_role_arn = var.ecs_application_task_role_arn
  container_definitions = jsonencode([
    {
      name : var.ecs_application_name
      image : "${var.ecs_application_registry_repository}/${var.ecs_application_name}:${var.ecs_application_version}",
      portMappings = [{
        containerPort = var.ecs_application_port
        hostPort      = var.ecs_application_port
      }],
      environment : length(var.ecs_application_environment) > 0 ? var.ecs_application_environment : null,
      cpu : 512,
      memory : 512,
      memoryReservation : 256,
      essential : true,
      logConfiguration = {
        logDriver = "awslogs",
        Options = {
          "awslogs-region"        = var.aws_region,
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_task_log_group.name,
          "awslogs-stream-prefix" = "ecs",
        }
      },
    },
  ])
  network_mode             = "bridge"
  cpu                      = 512
  memory                   = 512
  requires_compatibilities = ["EC2"]
  depends_on = [
    aws_cloudwatch_log_group.ecs_task_log_group,
  ]
}

resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.ecs_application_name}-${var.env}-service"
  cluster                            = "${var.ecs_cluster_name}-${var.env}"
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  scheduling_strategy                = "REPLICA"
  launch_type                        = "EC2"
  desired_count                      = lookup(var.ecs_application_deployment_count, "desired")
  deployment_minimum_healthy_percent = lookup(var.ecs_application_deployment_count, "minimum")
  deployment_maximum_percent         = lookup(var.ecs_application_deployment_count, "maximum")
  # network_configuration {
  #   subnets          = var.subnet_ids
  #   security_groups  = [aws_security_group.ec2_internal_sg.id]
  #   assign_public_ip = false
  # }
  load_balancer {
    target_group_arn = aws_lb_target_group.elb_target_group.arn
    container_name   = var.ecs_application_name
    container_port   = var.ecs_application_port
  }
  depends_on = [
    aws_ecs_task_definition.ecs_task_definition,
    aws_lb_target_group.elb_target_group,
  ]
}
