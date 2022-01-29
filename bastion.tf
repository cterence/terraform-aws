resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = local.bastion_public_key
}


resource "aws_launch_template" "bastion" {
  name = "bastion"

  update_default_version = true

  key_name = aws_key_pair.bastion.key_name

  image_id = "ami-0c6ebbd55ab05f070"
  iam_instance_profile {
    name = aws_iam_instance_profile.bastion.name
  }

  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.compute.id]
}

resource "aws_autoscaling_group" "this" {
  name             = "bastion"
  max_size         = 1
  min_size         = 1
  desired_capacity = 1
  force_delete     = true

  vpc_zone_identifier = [
    for subnet_name, subnet_attributes in local.app_subnets :
    aws_subnet.this[subnet_name].id
  ]

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
    value               = "bastion"
    propagate_at_launch = true
  }
}
