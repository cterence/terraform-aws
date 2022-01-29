output "vpc" {
  value = {
    arn        = aws_vpc.this.arn
    cidr_block = aws_vpc.this.cidr_block
    id         = aws_vpc.this.id
    tags       = aws_vpc.this.tags_all
  }
}

output "subnets" {
  value = {
    for subnet_name, subnet_attribute in aws_subnet.this :
    subnet_name => {
      arn               = subnet_attribute.arn
      id                = subnet_attribute.id
      availability_zone = subnet_attribute.availability_zone
      cidr_block        = subnet_attribute.cidr_block
      tags              = subnet_attribute.tags
    }
  }
}

output "cluster" {
  value = {
    arn      = aws_eks_cluster.this.arn
    endpoint = aws_eks_cluster.this.endpoint
    identity = aws_eks_cluster.this.identity
    tags     = aws_eks_cluster.this.tags_all
  }
}
