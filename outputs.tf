# TGW
output "tgw_id" {
  description   = "ID du Transit Gateway Principal"
  value         = module.tgw_principal.tgw_id
}

output "tgw_rt_core_id" {
  description   = "ID de la table de routage Core du Tgw"
  value         = module.tgw_principal.tgw_rt_core_id
}

output "tgw_rt_shared_id" {
  description   = "ID de la table de routage Shared du Tgw"
  value         = module.tgw_principal.tgw_rt_shared_id
}

output "tgw_rt_segregated_id" {
  description   = "ID de la table de routage Segragated du Tgw"
  value         = module.tgw_principal.tgw_rt_segregated_id
}

output "tgw_rt_onprem_id" {
  description   = "ID de la table de routage Onprem du Tgw"
  value         = module.tgw_principal.tgw_rt_onprem_id
}

output "ram_tgw_share_arns" {
  description   = "Liste des Arn des ressources share RAM pour Tgw"
  value         = module.tgw_principal.ram_tgw_share_arns
}

# VPC DEV
output "vpc_dev_id" {
  description   = "ID du VPC Dev"
  value         = module.vpc_dev.vpc_id
}

output "tgwattach_dev_id" {
  description   = "ID de l'attachement Tgw du VPC Dev"
  value         = module.vpc_dev.tgwattach_id
}

# VPC PROD
output "vpc_prod_id" {
  description   = "ID du VPC Prod"
  value         = module.vpc_prod.vpc_id
}

output "tgwattach_prod_id" {
  description   = "ID de l'attachement Tgw du VPC Prod"
  value         = module.vpc_prod.tgwattach_id
}

# VPC ENDPOINT
output "vpc_endpoint_id" {
  description   = "ID du VPC Endpoint"
  value         = module.vpc_endpoint.vpc_id
}

output "tgwattach_endpoint_id" {
  description   = "ID de l'attachement Tgw du VPC Endpoint"
  value         = module.vpc_endpoint.tgwattach_id
}

output "central_endpoints" {
  description   = "Liste des info des VPC endpoints deployes"
  value         = module.vpc_endpoint.central_endpoints
}

# VPC PERIMETRE
output "vpc_perimetre_id" {
  description   = "ID du VPC Perimetre"
  value         =module.vpc_perimetre.vpc_id
}

output "tgwattach_perimetre_id" {
  description   = "ID de l'attachement Tgw du VPC Perimetre"
  value         = module.vpc_perimetre.tgwattach_id
}

output "nfw_endpoint_1" {
  description   = "ID du VPC endpoint Nfw dans la zone a"
  value = module.vpc_perimetre.nfw_endpoint_1
}

output "nfw_endpoint_2" {
  description   = "ID du VPC endpoint Nfw dans la zone b"
  value = module.vpc_perimetre.nfw_endpoint_2
}

output "nfw_endpoints" {
  description   = "Liste des NFW endpoints"
  value = module.vpc_perimetre.nfw_endpoints
}

# VPC ONPREM
output "vpc_onprem_id" {
  description   = "ID du VPC Onprem"
  value         = module.vpc_onprem.vpc_id
}

output "vpc_onprem_cidr" {
  description   = "CIDR du VPC Onprem"
  value         = module.vpc_onprem.vpc_cidr
}

output "subnet_onprem_privatea_id" {
  description   = "ID du Subnet OnPrem Private-A"
  value         = module.vpc_onprem.subnet_privatea_id
}

output "subnet_onprem_publica_id" {
  description   = "ID du Subnet OnPrem Public-A"
  value         = module.vpc_onprem.subnet_publica_id
}

output "onprem_vpn_eip" {
  description   = "Info Elastic IP pour le server VPN"
  value         = module.vpc_onprem.onprem_vpn_eip
}

output "onprem_vpn_int_id" {
  description   = "ID de l'Interface privee du Server VPN"
  value         = module.vpc_onprem.onprem_vpn_int_id
}

# VPN ONPREM
output "vpn_server_instance_id" {
  description = "ID de l'instance du serveur VPN On Prem"
  value       = module.vpn_onprem.vpn_server_instance_id
}

# VPN CLOUD
output "vpn_connection_attributes" {
  description = "Configurations du VPN Cloud"
  sensitive = true
  value = module.vpn_cloud.vpn_connection_attributes
}