output "vpc_id" {
  description   = "ID du VPC Perimetre"
  value         = aws_vpc.perimetre.id
}

output "tgwattach_id" {
  description   = "ID de l'attachement Tgw du VPC Perimetre"
  value         = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}

output "nfw_endpoint_1" {
  description   = "ID du VPC endpoint Nfw dans la zone a"
  value = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[0]]
}

output "nfw_endpoint_2" {
  description   = "ID du VPC endpoint Nfw dans la zone b"
  value = local.nfw_endpoint_ids[data.aws_availability_zones.azs.names[1]]
}

output "nfw_endpoints" {
  description   = "Liste des NFW endpoints"
  value = flatten(aws_networkfirewall_firewall.perimetre.firewall_status[0].sync_states[*])
}