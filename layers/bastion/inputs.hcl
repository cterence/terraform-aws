dependency "network" {
  config_path = "../network"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  enabled         = true
  name            = "bastion"
  vpc_id          = dependency.network.outputs.vpc_id
  subnets         = dependency.network.outputs.private_subnets
  security_groups = [
    dependency.eks.outputs.cluster_security_group_id,
    dependency.eks.outputs.node_security_group_id
  ]
}
