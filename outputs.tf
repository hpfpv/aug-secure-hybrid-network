output "nfw_endpoint_1" {
  description   = "ID du VPC endpoint Nfw dans la zone a"
  value = module.vpc_perimetre.nfw_endpoint_1
}

output "nfw_endpoint_2" {
  description   = "ID du VPC endpoint Nfw dans la zone b"
  value = module.vpc_perimetre.nfw_endpoint_2
}

output "vpn_connection_attributes" {
  description = "Configurations du VPN Cloud"
  sensitive = true
  value = module.vpn_cloud.vpn_connection_attributes
}

output "central_endpoints" {
  description   = "Liste des ID des PHZ"
  value         = module.vpc_endpoint.central_endpoints_phz
}