include "root" {
  path           = find_in_parent_folders()
  merge_strategy = "deep"
}

include "inputs" {
  path = "./inputs.hcl"
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws//?version=19.10.0"
}
