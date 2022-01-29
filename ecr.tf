# Push stuff (example) :
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 766369807176.dkr.ecr.us-east-1.amazonaws.com
# docker pull node:18
# docker tag node:18 766369807176.dkr.ecr.us-east-1.amazonaws.com/node:18
# docker push 766369807176.dkr.ecr.us-east-1.amazonaws.com/node:18

resource "aws_ecr_repository" "ecr_registry" {
  for_each = local.ecrs
  name     = each.value.name
}
