resource "aws_eks_cluster" "this" {
  name     = "cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.compute.id]
    subnet_ids              = local.app_subnet_ids
  }

  tags = {
    Name = "cluster"
  }

  version = "1.21"
}

resource "aws_ami_copy" "eks_node_ami" {
  name              = "amazon_linux_2_eks_optimized_1_21"
  source_ami_id     = "ami-008ccec5b800d034b"
  source_ami_region = "eu-west-3"

  lifecycle {
    ignore_changes = [description]
  }

  tags = {
    Name = "amazon_linux_2_eks_optimized_1_21"
  }
}

resource "aws_launch_template" "eks_node" {
  name        = "eks_node"
  description = "Launch template for nodes of an EKS cluster"

  update_default_version = true

  block_device_mappings {
    device_name = aws_ami_copy.eks_node_ami.root_device_name

    ebs {
      delete_on_termination = true
      volume_size           = 8
      volume_type           = "gp2"
      encrypted             = false
      # kms_key_id            = data.aws_kms_key.this.arn
    }
  }

  image_id      = aws_ami_copy.eks_node_ami.id
  instance_type = "t3.micro"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "eks_node"
    }
  }

  vpc_security_group_ids = [aws_security_group.compute.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash

    # Install SSM agent
    yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

    # Execute the script to join the cluster
    /etc/eks/bootstrap.sh ${aws_eks_cluster.this.name}
    EOF
  )
}

resource "aws_eks_node_group" "blue" {
  cluster_name    = aws_eks_cluster.this.name
  node_role_arn   = aws_iam_role.eks_node.arn
  node_group_name = "blue"
  capacity_type   = "SPOT"

  launch_template {
    name    = aws_launch_template.eks_node.name
    version = aws_launch_template.eks_node.default_version
  }

  scaling_config {
    min_size     = 1
    max_size     = 1
    desired_size = 1
  }
  subnet_ids = local.app_subnet_ids

  tags = {
    Name = "blue"
  }
}
