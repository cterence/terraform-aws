terraform {
  cloud {
    organization = "terencec"
    workspaces {
      name = "aws-sandbox"
    }
  }
}
