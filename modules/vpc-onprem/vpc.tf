################################################################################
# VPC
################################################################################

resource "aws_vpc" "onprem" {
  cidr_block = var.vpc_cidr

  tags = {
      Name = "${var.resource_prefix}-onprem"
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.onprem.id
  cidr_block = var.subnet_privatea_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
      Name = "${var.resource_prefix}-subnet-private-a"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.onprem.id
  cidr_block = var.subnet_publica_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
      Name = "${var.resource_prefix}-subnet-public-a"
  }
}

################################################################################
# Internet Gateway et Nat
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.onprem.id

  tags = {
      Name = "${var.resource_prefix}-igw-onprem"
  }
}

resource "aws_eip" "nat_a" {
  depends_on                = [aws_internet_gateway.igw]
  domain = "vpc"

  tags = {
      Name = "${var.resource_prefix}-onprem-nat-a"
  }
}

resource "aws_nat_gateway" "nat_gateway_a" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
      Name = "${var.resource_prefix}-onprem-natgw-a"
  }
}

################################################################################
# Tables de routage VPC
################################################################################

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.onprem.id

  tags = {
      Name = "${var.resource_prefix}-onprem-rt-privatea"
  }
}

resource "aws_route" "internet_private_route_a" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_a.id
}

resource "aws_route" "cloud_private_route_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = var.cloud_cidr
  network_interface_id   = aws_network_interface.vpn_server_private_interface.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

############################################################################

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.onprem.id

  tags = {
      Name = "${var.resource_prefix}-onprem-rt-publica"
  }
}

resource "aws_route" "internet_public_route_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "cloud_public_route_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = var.cloud_cidr
  network_interface_id   = aws_network_interface.vpn_server_private_interface.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

################################################################################
# Security Group Server VPN
################################################################################

resource "aws_security_group" "vpn_server_sg" {
  name = "${var.resource_prefix}-vpn-server-sg"
  description = "SG pour le server VPN OnPrem"
  vpc_id = aws_vpc.onprem.id

  ingress {
    description         = "SSH from internet"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
    ipv6_cidr_blocks    = []
  }

  ingress {
    description         = "VPN Cloud"
    from_port           = 4500
    to_port             = 4500
    protocol            = "udp"
    cidr_blocks         = ["${var.cloud_vpn_config.tunnel1_address}/32", "${var.cloud_vpn_config.tunnel2_address}/32"]
    ipv6_cidr_blocks    = []
  }

    ingress {
    description         = "VPN Cloud"
    from_port           = 500
    to_port             = 500
    protocol            = "udp"
    cidr_blocks         = ["${var.cloud_vpn_config.tunnel1_address}/32", "${var.cloud_vpn_config.tunnel2_address}/32"]
    ipv6_cidr_blocks    = []
  }

  ingress {
    description         = "Allow all from VPC"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = [var.vpc_cidr]
    ipv6_cidr_blocks    = []
  }

  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
    ipv6_cidr_blocks    = ["::/0"]
  }

  tags = {
      Name = "${var.resource_prefix}-vpn-server-sg"
  }
}

################################################################################
# Interface du Server VPN
################################################################################

resource "aws_eip" "onprem_vpn_ip" {
  domain = "vpc"

  tags = {
      Name = "${var.resource_prefix}-onprem-vpn-ip"
  }
}

resource "aws_network_interface" "vpn_server_private_interface" {
  subnet_id               = aws_subnet.public_a.id
  private_ips             = var.server_vpn_private_ips
  security_groups         = [aws_security_group.vpn_server_sg.id]
  source_dest_check       = false

  tags = {
    Name = "${var.resource_prefix}-vpn-server-private-interface"
  }
}

resource "aws_eip_association" "eip_assoc" {
  network_interface_id   = aws_network_interface.vpn_server_private_interface.id
  allocation_id          = aws_eip.onprem_vpn_ip.id
}