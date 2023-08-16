################################################################################
# VPC
################################################################################

resource "aws_vpc" "endpoint" {
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
      Name = "${var.resource_prefix}-vpc-endpoint"
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "tgwattach_a" {
  vpc_id            = aws_vpc.endpoint.id
  cidr_block        = var.subnet_tgwattacha_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
      Name = "${var.resource_prefix}-subnet-tgwattach-a"
  }
}

resource "aws_subnet" "tgwattach_b" {
  vpc_id            = aws_vpc.endpoint.id
  cidr_block        = var.subnet_tgwattachb_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
      Name = "${var.resource_prefix}-subnet-tgwattach-b"
  }
}

resource "aws_subnet" "endpoint_a" {
  vpc_id     = aws_vpc.endpoint.id
  cidr_block = var.subnet_endpointa_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
      Name = "${var.resource_prefix}-subnet-endpoint-a"
  }
}

resource "aws_subnet" "endpoint_b" {
  vpc_id     = aws_vpc.endpoint.id
  cidr_block = var.subnet_endpointb_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
      Name = "${var.resource_prefix}-subnet-endpoint-b"
  }
}

################################################################################
# Tables de routage VPC
################################################################################

resource "aws_route_table" "endpoint" {
  vpc_id = aws_vpc.endpoint.id

  tags = {
      Name = "${var.resource_prefix}-vpc-endpoint-rt"
  }
}

resource "aws_route" "tgw_route" {
  route_table_id         = aws_route_table.endpoint.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id        = var.tgw_principal_id
}

resource "aws_route_table_association" "tgw_route_tgw_a" {
  subnet_id      = aws_subnet.tgwattach_a.id
  route_table_id = aws_route_table.endpoint.id
}

resource "aws_route_table_association" "tgw_route_tgw_b" {
  subnet_id      = aws_subnet.tgwattach_b.id
  route_table_id = aws_route_table.endpoint.id
}

resource "aws_route_table_association" "tgw_route_endpoint_a" {
  subnet_id      = aws_subnet.endpoint_a.id
  route_table_id = aws_route_table.endpoint.id
}

resource "aws_route_table_association" "tgw_route_endpoint_b" {
  subnet_id      = aws_subnet.endpoint_b.id
  route_table_id = aws_route_table.endpoint.id
}

################################################################################
# VPC Endpoints
################################################################################

resource "aws_security_group" "endpoint" {
  name        = "${var.resource_prefix}-sg-endpoint-https"
  description = "Allow https inbound traffic"
  vpc_id      = aws_vpc.endpoint.id

  ingress {
    description      = "HTTPS from CIDR"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-sg-endpoint-https"
  }
}

resource "aws_vpc_endpoint" "service" {
  count             = length(var.services)
  vpc_id            = aws_vpc.endpoint.id
  service_name      = "com.amazonaws.${var.region}.${var.services[count.index]}"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.endpoint_a.id, aws_subnet.endpoint_b.id]

  security_group_ids = [
    aws_security_group.endpoint.id,
  ]

  private_dns_enabled = false

  tags = {
      Name = "${var.resource_prefix}-endpoint-${var.services[count.index]}"
  }
}

################################################################################
# Creation des Private Hosted Zones pour les Endpoints
################################################################################

resource "aws_route53_zone" "phz" {
  count = length(var.services)
  name  = "${var.services[count.index]}.${var.region}.amazonaws.com"

  vpc {
    vpc_id     = aws_vpc.endpoint.id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "vpce_records" {
  count = length(aws_route53_zone.phz)
  zone_id = aws_route53_zone.phz[count.index].zone_id
  name    = aws_route53_zone.phz[count.index].name
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.service[count.index].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.service[count.index].dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
}

################################################################################
# Attachement Tgw et Association/ Propagation table de routage
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids             = [aws_subnet.tgwattach_a.id, aws_subnet.tgwattach_b.id]
  transit_gateway_id     = var.tgw_principal_id
  vpc_id                 = aws_vpc.endpoint.id

  tags = {
      Name = "${var.resource_prefix}-vpc-endpoint-tgwattach"
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