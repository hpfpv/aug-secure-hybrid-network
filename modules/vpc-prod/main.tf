################################################################################
# VPC
################################################################################

resource "aws_vpc" "prod" {
  cidr_block = var.vpc_cidr

  tags = {
      Name = "${var.resource_prefix}-vpc-prod"
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "tgwattach_a" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = var.subnet_tgwattacha_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
      Name = "${var.resource_prefix}-subnet-tgwattach-a"
  }
}

resource "aws_subnet" "tgwattach_b" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = var.subnet_tgwattachb_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
      Name = "${var.resource_prefix}-subnet-tgwattach-b"
  }
}

resource "aws_subnet" "app_a" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = var.subnet_appa_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
      Name = "${var.resource_prefix}-subnet-app-a"
  }
}

resource "aws_subnet" "app_b" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = var.subnet_appb_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
      Name = "${var.resource_prefix}-subnet-app-b"
  }
}

################################################################################
# Tables de routage VPC
################################################################################

resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.prod.id

  tags = {
      Name = "${var.resource_prefix}-vpc-prod-rt"
  }
}

resource "aws_route" "tgw_route" {
  route_table_id         = aws_route_table.prod.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id        = var.tgw_principal_id
}

resource "aws_route_table_association" "tgw_route_tgw_a" {
  subnet_id      = aws_subnet.tgwattach_a.id
  route_table_id = aws_route_table.prod.id
}

resource "aws_route_table_association" "tgw_route_tgw_b" {
  subnet_id      = aws_subnet.tgwattach_b.id
  route_table_id = aws_route_table.prod.id
}

resource "aws_route_table_association" "tgw_route_app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.prod.id
}

resource "aws_route_table_association" "tgw_route_app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.prod.id
}

################################################################################
# Attachement Tgw et Association/ Propagation table de routage
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids             = [aws_subnet.tgwattach_a.id, aws_subnet.tgwattach_b.id]
  transit_gateway_id     = var.tgw_principal_id
  vpc_id                 = aws_vpc.prod.id

  tags = {
      Name = "${var.resource_prefix}-vpc-prod-tgwattach"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_association" {
  count = length(var.tgw_association_route_table_ids)

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
  transit_gateway_route_table_id = var.tgw_association_route_table_ids[count.index]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_table_propagation" {
  count = length(var.tgw_propagation_route_table_ids)

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
  transit_gateway_route_table_id = var.tgw_propagation_route_table_ids[count.index]
}

################################################################################
# Association Private Hosted Zone Central Endpoints
################################################################################

resource "aws_route53_zone_association" "endpoint" {
  count = var.use_central_endpoints ? length(var.central_endpoints_phz) : 0
  zone_id = var.central_endpoints_phz[count.index]
  vpc_id  = aws_vpc.prod.id
}

################################################################################
# Partage des Subnets
################################################################################
resource "aws_ram_resource_share" "subnet_share" {
  name                      = "${var.resource_prefix}-vpc-dev-share"
  allow_external_principals = false  # true for accounts outside organization
}

resource "aws_ram_principal_association" "principal" {
  count               = length(var.subnet_sharing_principals)
  principal           = var.subnet_sharing_principals[count.index]
  resource_share_arn  = aws_ram_resource_share.subnet_share.arn
}

resource "aws_ram_resource_association" "subnet" {
  count               = length(local.subnet_to_share)
  resource_arn       = local.subnet_to_share[count.index]
  resource_share_arn = aws_ram_resource_share.subnet_share.arn
}