################################################################################
# Association/ Propagation table de routage pour le VPC Perimetre
################################################################################

resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_association" {
  count = length(var.tgw_association_route_table_ids)

  transit_gateway_attachment_id = var.vpc_perimetre_tgwattach_id
  transit_gateway_route_table_id = var.tgw_association_route_table_ids[count.index]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_table_propagation" {
  count = length(var.tgw_propagation_route_table_ids)

  transit_gateway_attachment_id  = var.vpc_perimetre_tgwattach_id
  transit_gateway_route_table_id = var.tgw_propagation_route_table_ids[count.index]
}

################################################################################
# Routes 0 pour internet dans les route tables shared et segregated Tgw
################################################################################

resource "aws_ec2_transit_gateway_route" "shared_internet" { # Route pour internet de puis le VPC Endpoint - Central
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_route_table_id = var.tgw_rt_shared_id
  transit_gateway_attachment_id  = var.vpc_perimetre_tgwattach_id
}

resource "aws_ec2_transit_gateway_route" "segregated_internet" { # Route pour internet de puis les VPC Dev - Test - Prod
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_route_table_id = var.tgw_rt_segregated_id
  transit_gateway_attachment_id  = var.vpc_perimetre_tgwattach_id
}