terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }
  }

  required_version = "~> 1"
}

provider "aws" {
  region  = "eu-west-3"
  profile = "terraform"

  default_tags {
    tags = {
      Environment = "sandbox"
      Owner       = "terence"
    }
  }
}
