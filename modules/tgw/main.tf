resource "aws_ec2_transit_gateway" "tgw" {

  description                     = "Transit Gateway Principal"
  amazon_side_asn                 = 65521
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"
  vpn_ecmp_support                = "enable"
  dns_support                     = "enable"

  tags = { Name = "${var.resource_prefix}-tgw-principal" }
}

################################################################################
# Route Table / Routes
################################################################################

resource "aws_ec2_transit_gateway_route_table" "core" { # Table de routage associée aux VPC Perimetre - Endpoint - Central
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = { Name = "${var.resource_prefix}-tgw-principal-rt-core" }
}

resource "aws_ec2_transit_gateway_route_table" "shared" { # Table de routage associée au VPC Endpoint - Central
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = { Name = "${var.resource_prefix}-tgw-principal-rt-shared" }
}

resource "aws_ec2_transit_gateway_route_table" "segregated" { # Table de routage associée aux VPC Dev - Test - Prod
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = { Name = "${var.resource_prefix}-tgw-principal-rt-segregated" }
}

resource "aws_ec2_transit_gateway_route_table" "onprem" { # Table de routage associée au Data center on prem
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = { Name = "${var.resource_prefix}-tgw-principal-rt-onprem" }
}

################################################################################
# Resource Access Manager - Partage du Tgw aux comptes
################################################################################

resource "aws_ram_resource_share" "ram_tgw_principal" {
  name                      = "${var.resource_prefix}-share-tgw"
  allow_external_principals = true
  
  tags = { Name = "${var.resource_prefix}-share-tgw" }
}

resource "aws_ram_resource_association" "ram_tgw_principal_association" {
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
  resource_share_arn = aws_ram_resource_share.ram_tgw_principal.id
}

resource "aws_ram_principal_association" "ram_tgw_principal_share" {
  count = length(var.ram_principals)

  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.ram_tgw_principal.arn
}