locals {
  subnets = {
    app_1 = {
      availability_zone = "eu-west-3a"
      cidr_block        = "10.0.0.0/18"
    }

    app_2 = {
      availability_zone = "eu-west-3b"
      cidr_block        = "10.0.64.0/18"
    }

    pub_1 = {
      availability_zone = "eu-west-3a"
      cidr_block        = "10.0.128.0/19"
    },

    pub_2 = {
      availability_zone = "eu-west-3b"
      cidr_block        = "10.0.160.0/19"
    }

    data_1 = {
      availability_zone = "eu-west-3a"
      cidr_block        = "10.0.192.0/19"
    }

    data_2 = {
      availability_zone = "eu-west-3b"
      cidr_block        = "10.0.224.0/19"
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

  data_subnets = {
    for subnet_name, subnet_attributes in local.subnets :
    subnet_name => subnet_attributes if length(regexall("data_[12]", subnet_name)) > 0
  }

  bastion_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHf7O+dU4jfkgWfqGKFDG3kZ1OA98C/aEuR9Z6CJi+0 terence@pop-os"

  ssm_vpc_endpoint_services = [
    "com.amazonaws.eu-west-3.ssm",
    "com.amazonaws.eu-west-3.ssmmessages",
    "com.amazonaws.eu-west-3.ec2messages",
  ]
}
