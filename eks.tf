###################
### EKS cluster ###
###################

resource "aws_eks_cluster" "this" {
  name     = local.eks.cluster.name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
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
resource "aws_eks_node_group" "blue" {
  cluster_name    = aws_eks_cluster.this.name
  node_role_arn   = aws_iam_role.eks_node.arn
  node_group_name = "blue"
  capacity_type   = local.eks.node.capacity_type
  instance_types  = local.eks.node.instance_types


  scaling_config {
    min_size     = local.eks.node.scaling_config.min_size
    max_size     = local.eks.node.scaling_config.max_size
    desired_size = local.eks.node.scaling_config.desired_size
  }

  subnet_ids = local.app_subnet_ids

  tags = {
    Name = "blue"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_node_group" "green" {
  cluster_name    = aws_eks_cluster.this.name
  node_role_arn   = aws_iam_role.eks_node.arn
  node_group_name = "green"
  capacity_type   = local.eks.node.capacity_type
  instance_types  = local.eks.node.instance_types

  scaling_config {
    min_size     = local.eks.node.scaling_config.min_size
    max_size     = local.eks.node.scaling_config.max_size
    desired_size = local.eks.node.scaling_config.desired_size
  }

  subnet_ids = local.app_subnet_ids

  tags = {
    Name = "green"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
