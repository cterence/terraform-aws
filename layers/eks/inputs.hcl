dependency "network" {
  config_path = "../network"
}

inputs = {
  cluster_name    = "sandbox-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = false

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    capacity_type  = "SPOT"
    instance_types = ["t3a.micro"]
  }

  eks_managed_node_groups = {
    blue = {}
  }
}
