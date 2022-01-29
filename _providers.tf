terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  required_version = "~> 1"
}

provider "aws" {
  region  = "us-east-1"
  profile = "padok-lab"

  default_tags {
    tags = {
      Environment = "dojo-ci-cd-rezel"
      Owner       = "padok"
    }
  }
}
