###########
### VPC ###
###########

resource "aws_vpc" "this" {
  cidr_block           = local.vpc.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = local.vpc.name
  }
}

###############
### Subnets ###
###############

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  tags = {
    Name = each.key
  }
}


################
### Gateways ###
################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.gateways.igw_name
  }
}

resource "aws_eip" "this" {
  for_each = local.public_subnets

  tags = {
    Name = "eip_${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = local.public_subnets

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.this[each.key].id

  tags = {
    Name = "ngw_${each.key}"
  }
}

#################### 
### Route tables ###
#################### 

resource "aws_route_table" "app" {
  for_each = local.app_subnets

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this["pub_${index(keys(local.app_subnets), each.key) + 1}"].id
  }
}

resource "aws_route_table" "pub" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "app" {
  for_each = local.app_subnets

  route_table_id = aws_route_table.app[each.key].id
  subnet_id      = aws_subnet.this[each.key].id
}

resource "aws_route_table_association" "pub" {
  for_each = local.public_subnets

  route_table_id = aws_route_table.pub[each.key].id
  subnet_id      = aws_subnet.this[each.key].id
}

#####################
### VPC endpoints ###
#####################

resource "aws_vpc_endpoint" "this" {
  for_each = toset(local.bastion_vpc_endpoints.services)

  service_name        = each.key
  vpc_endpoint_type   = local.bastion_vpc_endpoints.type
  vpc_id              = aws_vpc.this.id
  subnet_ids          = local.app_subnet_ids
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.compute.id]
}

#######################
### Security groups ###
#######################
resource "aws_security_group" "compute" {
  name        = local.security_groups.compute.name
  description = local.security_groups.compute.description
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
