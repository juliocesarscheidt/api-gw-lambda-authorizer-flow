resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-ecs-${var.env}"
  role = aws_iam_role.ec2_role.name
  depends_on = [
    aws_iam_role.ec2_role,
  ]
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")
  vars = {
    ECS_CLUSTER = "${var.ecs_cluster_name}-${var.env}"
    VOLUME_SIZE = var.ec2_instance_volume_size
  }
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_launch_template" "ec2_launch_template" {
  name          = "ec2-launch-template-ecs-${var.env}"
  image_id      = var.ec2_ami_id == "" ? data.aws_ami.amazon_linux_ecs.id : var.ec2_ami_id
  instance_type = var.ec2_instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  key_name = aws_key_pair.ec2_key_pair.key_name
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_internal_sg.id]
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = var.ec2_instance_volume_size
      delete_on_termination = true
    }
  }
  tags = merge(var.tags, {
    "Name" = "ec2-launch-template-ecs-${var.env}"
  })
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      "Name" = "ec2-instance-ecs-${var.env}"
    })
  }
  user_data = base64encode(data.template_file.user_data.rendered)
  depends_on = [
    aws_security_group.ec2_internal_sg,
  ]
}
