###################
### EKS cluster ###
###################

resource "aws_eks_cluster" "this" {
  name     = local.eks.cluster.name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.compute.id]
    subnet_ids              = local.app_subnet_ids
  }

  tags = {
    Name = local.eks.cluster.name
  }

  version = local.eks.cluster.version
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_launch_template" "eks_node" {
  name        = local.eks.node.name
  description = local.eks.node.lt_description

  update_default_version = true

  block_device_mappings {
    device_name = local.eks.node.image.device_name

    ebs {
      delete_on_termination = local.eks.node.ebs.delete_on_termination
      volume_size           = local.eks.node.ebs.volume_size
      volume_type           = local.eks.node.ebs.volume_type
      encrypted             = local.eks.node.ebs.encrypted
      # kms_key_id            = data.aws_kms_key.this.arn
    }
  }

  image_id      = local.eks.node.image.id
  instance_type = local.eks.node.instance_type

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.eks.node.name
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
  capacity_type   = local.eks.node.capacity_type

  launch_template {
    name    = aws_launch_template.eks_node.name
    version = aws_launch_template.eks_node.default_version
  }

  scaling_config {
    min_size     = local.eks.node.scaling_config.min_size
    max_size     = local.eks.node.scaling_config.max_size
    desired_size = local.eks.node.scaling_config.desired_size
  }

  subnet_ids = local.app_subnet_ids

  tags = {
    Name = "blue"
  }
}

resource "aws_eks_node_group" "green" {
  cluster_name    = aws_eks_cluster.this.name
  node_role_arn   = aws_iam_role.eks_node.arn
  node_group_name = "green"
  capacity_type   = local.eks.node.capacity_type

  launch_template {
    name    = aws_launch_template.eks_node.name
    version = aws_launch_template.eks_node.default_version
  }

  scaling_config {
    min_size     = local.eks.node.scaling_config.min_size
    max_size     = local.eks.node.scaling_config.max_size
    desired_size = local.eks.node.scaling_config.desired_size
  }

  subnet_ids = local.app_subnet_ids

  tags = {
    Name = "green"
  }
}
