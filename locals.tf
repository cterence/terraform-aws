locals {

  # Network
  vpc = {
    name       = "dojo_ci_cd_rezel"
    cidr_block = "10.0.0.0/16"
  }

  subnets = {
    app_1 = {
      availability_zone = "us-east-1a"
      cidr_block        = "10.0.0.0/18"
    }

    app_2 = {
      availability_zone = "us-east-1b"
      cidr_block        = "10.0.64.0/18"
    }

    pub_1 = {
      availability_zone = "us-east-1a"
      cidr_block        = "10.0.128.0/18"
    },

    pub_2 = {
      availability_zone = "us-east-1b"
      cidr_block        = "10.0.192.0/18"
    }
  }

  app_subnets = {
    for subnet_name, subnet_attributes in local.subnets :
    subnet_name => subnet_attributes if length(regexall("app_[12]", subnet_name)) > 0
  }

  public_subnets = {
    for subnet_name, subnet_attributes in local.subnets :
    subnet_name => subnet_attributes if length(regexall("pub_[12]", subnet_name)) > 0
  }

  app_subnet_ids = [
    for subnet_name in keys(local.app_subnets) :
    aws_subnet.this[subnet_name].id
  ]

  public_subnet_ids = [
    for subnet_name in keys(local.public_subnets) :
    aws_subnet.this[subnet_name].id
  ]

  gateways = {
    igw_name = "igw"
  }

  # EKS

  eks = {
    cluster = {
      name    = "dojo_ci_cd_rezel"
      version = "1.21"
    }
    node = {
      name           = "eks_node"
      capacity_type  = "SPOT"
      instance_types = ["t3a.xlarge", "c6a.xlarge", "c5a.xlarge", "t3.xlarge", "c5.xlarge", "c6i.xlarge", "m5a.xlarge", "m6a.xlarge"]
      scaling_config = {
        min_size     = 1
        max_size     = 100
        desired_size = 1
      }
    }
  }

  ecr = {
    "node" = {
      name = "node"
    }
  }
}
