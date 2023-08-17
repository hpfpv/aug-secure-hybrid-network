################################################################################
# Transit Gateway
################################################################################

variable "ram_principals" {
    description         = "Une liste de principals avec lesquels partager TGW. Les valeurs possibles sont un ID de compte AWS, un ARN d'organisation AWS Organizations ou un ARN d'unité d'organisation AWS Organizations"
    type                = list(string)
}

variable "tgw_bgp_asn" {
    description         = "BGP ASN du Transit Gateway AWS"
    type                = number
}

################################################################################
# VPC Perimetre
################################################################################

variable "vpc_perimetre_cidr" {
    description         = "CIDR du VPC Perimetre"
    type                = string
}

variable "subnet_perimetre_tgwattacha_cidr" {
    description         = "CIDR du subnet Perimetre-Tgwattach-A"
    type                = string
}

variable "subnet_perimetre_tgwattachb_cidr" {
    description         = "CIDR du subnet Perimetre-Tgwattach-B"
    type                = string
}

variable "subnet_perimetre_nfwa_cidr" {
    description         = "CIDR du subnet Perimetre-Nfw-A"
    type                = string
}

variable "subnet_perimetre_nfwb_cidr" {
    description         = "CIDR du subnet Perimetre-Nfw-B"
    type                = string
}

variable "subnet_perimetre_nata_cidr" {
    description         = "CIDR du subnet Perimetre-Nat-A"
    type                = string
}

variable "subnet_perimetre_natb_cidr" {
    description         = "CIDR du subnet Perimetre-Nat-B"
    type                = string
}

################################################################################
# VPC Endpoint
################################################################################

variable "vpc_endpoint_cidr" {
    description         = "CIDR du VPC Endpoint"
    type                = string
}

variable "subnet_endpoint_tgwattacha_cidr" {
    description         = "CIDR du subnet Endpoint-Tgwattach-A"
    type                = string
}

variable "subnet_endpoint_tgwattachb_cidr" {
    description         = "CIDR du subnet Endpoint-Tgwattach-B"
    type                = string
}

variable "subnet_endpointa_cidr" {
    description         = "CIDR du subnet Endpoint-A"
    type                = string
}

variable "subnet_endpointb_cidr" {
    description         = "CIDR du subnet Endpoint-B"
    type                = string
}

################################################################################
# VPC Dev
################################################################################

variable "vpc_dev_cidr" {
    description         = "CIDR du VPC Dev"
    type                = string
}

variable "subnet_dev_tgwattacha_cidr" {
    description         = "CIDR du subnet Dev-Tgwattach-A"
    type                = string
}

variable "subnet_dev_tgwattachb_cidr" {
    description         = "CIDR du subnet Dev-Tgwattach-B"
    type                = string
}

variable "subnet_dev_appa_cidr" {
    description         = "CIDR du subnet Dev-App-A"
    type                = string
}

variable "subnet_dev_appb_cidr" {
    description         = "CIDR du subnet Dev-App-B"
    type                = string
}

################################################################################
# VPC Prod
################################################################################

variable "vpc_prod_cidr" {
    description         = "CIDR du VPC Prod"
    type                = string
}

variable "subnet_prod_tgwattacha_cidr" {
    description         = "CIDR du subnet Prod-Tgwattach-A"
    type                = string
}

variable "subnet_prod_tgwattachb_cidr" {
    description         = "CIDR du subnet Prod-Tgwattach-B"
    type                = string
}

variable "subnet_prod_appa_cidr" {
    description         = "CIDR du subnet Prod-App-A"
    type                = string
}

variable "subnet_prod_appb_cidr" {
    description         = "CIDR du subnet Prod-App-B"
    type                = string
}

################################################################################
# VPN AWS
################################################################################

variable "cgw_bgp_asn" {
    description         = "BGP ASN du Customer Gateway"
    type                = number
}

################################################################################
# VPC OnPrem
################################################################################

variable "cloud_cidr" {
    description         = "CIDR du Cloud"
    type                = string
}

variable "vpc_onprem_cidr" {
    description         = "CIDR du VPC OnPrem"
    type                = string
}

variable "subnet_onprem_privatea_cidr" {
    description         = "CIDR du Subnet OnPrem Private-A"
    type                = string
}

variable "subnet_onprem_publica_cidr" {
    description         = "CIDR du Subnet OnPrem Public-A"
    type                = string
}

variable "onprem_region" {
  description           = "Region AWS pour la creation des ressources On Prem"
  type                  = string
}

################################################################################
# VPN OnPrem
################################################################################

variable "server_vpn_private_ips" {
    description         = "Liste des IP Privees du server VPN dans le subnet Public-A"
    type                = list(string)
}

variable "server_vpn_instance_type" {
    description         = "Type de l'instance du server VPN"
    type                = string
}

################################################################################
# Commons variables
################################################################################
variable "assume_role_network" {
    description         = "Arn du role IAM a assumer pour deployer les ressources dans le compte Network (sandbox01)"
    type                = string
}

variable "assume_role_perimetre" {
    description         = "Arn du role IAM a assumer pour deployer les ressources dans le compte Perimetre (sandbox02)"
    type                = string
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
    default             = "aug-sec-network"
}

variable "region" {
  description           = "Region AWS pour la creation des ressources"
  type                  = string
}