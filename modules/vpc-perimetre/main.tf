################################################################################
# VPC
################################################################################

resource "aws_vpc" "perimetre" {
  cidr_block = var.vpc_cidr

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre"
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "tgwattach_a" {
  vpc_id     = aws_vpc.perimetre.id
  cidr_block = var.subnet_tgwattacha_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
      Name = "${var.resource_prefix}-subnet-tgwattach-a"
  }
}

resource "aws_subnet" "tgwattach_b" {
  vpc_id     = aws_vpc.perimetre.id
  cidr_block = var.subnet_tgwattachb_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
      Name = "${var.resource_prefix}-subnet-tgwattach-b"
  }
}

resource "aws_subnet" "nfw_a" {
  vpc_id     = aws_vpc.perimetre.id
  cidr_block = var.subnet_nfwa_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
      Name = "${var.resource_prefix}-subnet-nfw-a"
  }
}

resource "aws_subnet" "nfw_b" {
  vpc_id     = aws_vpc.perimetre.id
  cidr_block = var.subnet_nfwb_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
      Name = "${var.resource_prefix}-subnet-nfw-b"
  }
}

resource "aws_subnet" "nat_a" {
  vpc_id     = aws_vpc.perimetre.id
  cidr_block = var.subnet_nata_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
      Name = "${var.resource_prefix}-subnet-nat-a"
  }
}

resource "aws_subnet" "nat_b" {
  vpc_id     = aws_vpc.perimetre.id
  cidr_block = var.subnet_natb_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true

  tags = {
      Name = "${var.resource_prefix}-subnet-nat-b"
  }
}

################################################################################
# Internet Gateway et Nat
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-igw-perimetre"
  }
}

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-nat-a"
  }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-nat-b"
  }
}

resource "aws_nat_gateway" "nat_gateway_a" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.nat_a.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-natgw-a"
  }
}

resource "aws_nat_gateway" "nat_gateway_b" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.nat_b.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-natgw-b"
  }
}

################################################################################
# Tables de routage VPC
################################################################################

resource "aws_route_table" "tgwattach_a" {
  vpc_id = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-rt-tgwa"
  }
}

resource "aws_route" "tgw_nfw_route_a" {
  route_table_id         = aws_route_table.tgwattach_a.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[0]]
}

resource "aws_route" "tgwa_nfw_route_nat_a" { # Trafic vers les ALB dans le subnet Nat-A, bypass de la route local du VPC pour eviter un drop au niveau du NFW
  route_table_id         = aws_route_table.tgwattach_a.id
  destination_cidr_block = var.subnet_nata_cidr
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[0]]
}

resource "aws_route" "tgwa_nfw_route_nat_b" { # Trafic vers les ALB dans le subnet Nat-B, bypass de la route local du VPC pour eviter un drop au niveau du NFW
  route_table_id         = aws_route_table.tgwattach_a.id
  destination_cidr_block = var.subnet_natb_cidr
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[1]]
}

resource "aws_route_table_association" "tgwattach_a" {
  subnet_id      = aws_subnet.tgwattach_a.id
  route_table_id = aws_route_table.tgwattach_a.id
}

resource "aws_route_table" "tgwattach_b" {
  vpc_id = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-rt-tgwb"
  }
}

resource "aws_route" "tgwb_nfw_route_b" {
  route_table_id         = aws_route_table.tgwattach_b.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[1]]
}

resource "aws_route" "tgwb_nfw_route_nat_a" { # Trafic vers les ALB dans le subnet Nat-A, bypass de la route local du VPC pour eviter un drop au niveau du NFW
  route_table_id         = aws_route_table.tgwattach_b.id
  destination_cidr_block = var.subnet_nata_cidr
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[0]]
}

resource "aws_route" "tgw_nfw_route_nat_b" { # Trafic vers les ALB dans le subnet Nat-B, bypass de la route local du VPC pour eviter un drop au niveau du NFW
  route_table_id         = aws_route_table.tgwattach_b.id
  destination_cidr_block = var.subnet_natb_cidr
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[1]]
}
resource "aws_route_table_association" "tgwattach_b" {
  subnet_id      = aws_subnet.tgwattach_b.id
  route_table_id = aws_route_table.tgwattach_b.id
}

################################################################################

resource "aws_route_table" "nfw_a" {
  vpc_id = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-rt-nfwa"
  }
}

resource "aws_route" "nfw_nat_route_a" {
  route_table_id         = aws_route_table.nfw_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_a.id
}

resource "aws_route" "nfw_tgw_route_a" {
  route_table_id         = aws_route_table.nfw_a.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id        = var.tgw_principal_id
}

resource "aws_route_table_association" "nfw_a" {
  subnet_id      = aws_subnet.nfw_a.id
  route_table_id = aws_route_table.nfw_a.id
}

resource "aws_route_table" "nfw_b" {
  vpc_id = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-rt-nfwb"
  }
}

resource "aws_route" "nfw_nat_route_b" {
  route_table_id         = aws_route_table.nfw_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_b.id
}

resource "aws_route" "nfw_tgw_route_b" {
  route_table_id         = aws_route_table.nfw_b.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id        = var.tgw_principal_id
}

resource "aws_route_table_association" "nfw_b" {
  subnet_id      = aws_subnet.nfw_b.id
  route_table_id = aws_route_table.nfw_b.id
}

################################################################################

resource "aws_route_table" "nat_a" {
  vpc_id = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-rt-nata"
  }
}

resource "aws_route" "nat_nfw_route_a" {
  route_table_id         = aws_route_table.nat_a.id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[0]]
}

resource "aws_route" "nat_igw_route_a" {
  route_table_id         = aws_route_table.nat_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "nat_a" {
  subnet_id      = aws_subnet.nat_a.id
  route_table_id = aws_route_table.nat_a.id
}

resource "aws_route_table" "nat_b" {
  vpc_id = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-rt-natb"
  }
}

resource "aws_route" "nat_nfw_route_b" {
  route_table_id         = aws_route_table.nat_b.id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[1]]
}

resource "aws_route" "nat_igw_route_b" {
  route_table_id         = aws_route_table.nat_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "nat_b" {
  subnet_id      = aws_subnet.nat_b.id
  route_table_id = aws_route_table.nat_b.id
}

################################################################################
# Attachement Tgw et Association/ Propagation table de routage
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids             = [aws_subnet.tgwattach_a.id, aws_subnet.tgwattach_b.id]
  transit_gateway_id     = var.tgw_principal_id
  appliance_mode_support  = "enable"
  vpc_id                 = aws_vpc.perimetre.id

  tags = {
      Name = "${var.resource_prefix}-vpc-perimetre-tgwattach"
  }
}

################################################################################
# Acceptation du Share de la Tgw du compte Network
################################################################################

resource "aws_ram_resource_share_accepter" "ram_tgw_principal_accept" {
  count = length(var.ram_tgw_resource_share_arns)
  share_arn = var.ram_tgw_resource_share_arns[count.index]
}

################################################################################
# Association Private Hosted Zone Central Endpoints
################################################################################

resource "aws_route53_zone_association" "endpoint" {
  count = var.use_central_endpoints ? length(var.central_endpoints_phz) : 0
  zone_id = var.central_endpoints_phz[count.index]
  vpc_id  = aws_vpc.perimetre.id
}