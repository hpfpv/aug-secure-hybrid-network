################################################################################
# VPN
################################################################################

resource "aws_customer_gateway" "cgw" {
  bgp_asn           = var.cgw_bgp_asn
  ip_address        = var.cgw_ip
  type              = "ipsec.1"

  tags = {
      Name = "${var.resource_prefix}-cgw"
  }
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id         = aws_customer_gateway.cgw.id
  transit_gateway_id          = var.tgw_principal_id
  static_routes_only          = false
  type                        = aws_customer_gateway.cgw.type

  tags = {
      Name = "${var.resource_prefix}-vpn"
  }
}

################################################################################
# Attachement Tgw et Association/ Propagation table de routage
################################################################################

resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_association" {
  count = length(var.tgw_association_route_table_ids)

  transit_gateway_attachment_id  = aws_vpn_connection.vpn.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_association_route_table_ids[count.index]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_table_propagation" {
  count = length(var.tgw_propagation_route_table_ids)

  transit_gateway_attachment_id  = aws_vpn_connection.vpn.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_propagation_route_table_ids[count.index]
}