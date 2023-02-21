include "root" {
  path           = find_in_parent_folders()
  merge_strategy = "deep"
}

include "inputs" {
  path = "./inputs.hcl"
}

terraform {
  source = "tfr:///cloudposse/ec2-bastion-server/aws//?version=0.30.1"
}
