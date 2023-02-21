include "root" {
  path           = find_in_parent_folders()
  merge_strategy = "deep"
}

include "inputs" {
  path = "./inputs.hcl"
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//?version=3.19.0"
}
