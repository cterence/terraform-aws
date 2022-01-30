locals {

  # Network
  vpc = {
    name       = "main"
    cidr_block = "10.0.0.0/16"
  }

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

  app_subnet_ids = [
    for subnet_name in keys(local.app_subnets) :
    aws_subnet.this[subnet_name].id
  ]

  public_subnet_ids = [
    for subnet_name in keys(local.public_subnets) :
    aws_subnet.this[subnet_name].id
  ]

  data_subnet_ids = [
    for subnet_name in keys(local.data_subnets) :
    aws_subnet.this[subnet_name].id
  ]

  gateways = {
    igw_name = "igw"
  }

  bastion_vpc_endpoints = {
    type = "Interface"
    services = [
      "com.amazonaws.eu-west-3.ssm",
      "com.amazonaws.eu-west-3.ssmmessages",
      "com.amazonaws.eu-west-3.ec2messages",
    ]
  }

  security_groups = {
    compute = {
      name        = "compute"
      description = "Allow compute resources traffic"
    }
  }

  # Bastion
  bastion = {
    name          = "bastion"
    image_id      = "ami-0c6ebbd55ab05f070"
    instance_type = "t2.micro"
    public_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHf7O+dU4jfkgWfqGKFDG3kZ1OA98C/aEuR9Z6CJi+0 terence@pop-os"
  }

  # EKS


  eks = {
    cluster = {
      name    = "eks_cluster"
      version = "1.21"
    }
    node = {
      name           = "eks_node"
      lt_description = "Launch template for nodes of an EKS cluster"
      image = {
        name   = "amazon_linux_2_eks_optimized_1_21"
        id     = "ami-008ccec5b800d034b"
        region = "eu-west-3"
      }
      capacity_type = "SPOT"
      ebs = {
        delete_on_termination = true
        volume_size           = 8
        volume_type           = "gp2"
        encrypted             = false
      }
      instance_type = "t3.micro"
      scaling_config = {
        min_size     = 1
        max_size     = 1
        desired_size = 1
      }
    }
  }
}
