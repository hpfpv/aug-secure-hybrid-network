output "tgw_id" {
  description   = "ID du Transit Gateway Principal"
  value         = aws_ec2_transit_gateway.tgw.id
}

output "tgw_rt_core_id" {
  description   = "ID de la table de routage Core du Tgw"
  value         = aws_ec2_transit_gateway_route_table.core.id
}

output "tgw_rt_shared_id" {
  description   = "ID de la table de routage Shared du Tgw"
  value         = aws_ec2_transit_gateway_route_table.shared.id
}

output "tgw_rt_segregated_id" {
  description   = "ID de la table de routage Segragated du Tgw"
  value         = aws_ec2_transit_gateway_route_table.segregated.id
}

output "tgw_rt_onprem_id" {
  description   = "ID de la table de routage Onprem du Tgw"
  value         = aws_ec2_transit_gateway_route_table.onprem.id
}

output "ram_tgw_share_arns" {
  description   = "Liste des Arn des ressources share RAM pour Tgw"
  value         = aws_ram_principal_association.ram_tgw_principal_share[*].resource_share_arn
}
