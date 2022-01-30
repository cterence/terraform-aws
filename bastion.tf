resource "aws_key_pair" "bastion" {
  key_name   = local.bastion.name
  public_key = local.bastion.public_key
}

resource "aws_launch_template" "bastion" {
  name = local.bastion.name

  update_default_version = true
  key_name               = aws_key_pair.bastion.key_name
  image_id               = local.bastion.image_id
  instance_type          = local.bastion.instance_type
  vpc_security_group_ids = [aws_security_group.compute.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.bastion.name
  }

  tags = {
    Name = local.bastion.name
  }
}

resource "aws_autoscaling_group" "this" {
  name             = local.bastion.name
  min_size         = 1
  max_size         = 1
  desired_capacity = 1
  force_delete     = true

  vpc_zone_identifier = local.app_subnet_ids

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = local.bastion.name
    propagate_at_launch = true
  }
}
