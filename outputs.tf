output "nfw_endpoint_1" {
  description   = "ID du VPC endpoint Nfw dans la zone a"
  value = module.vpc_perimetre.nfw_endpoint_1
}

output "nfw_endpoint_2" {
  description   = "ID du VPC endpoint Nfw dans la zone b"
  value = module.vpc_perimetre.nfw_endpoint_2
}

output "vpn_connection_attributes" {
  value = module.vpn.vpn_connection_attributes
}