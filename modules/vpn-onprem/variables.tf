variable "cloud_cidr" {
    description         = "CIDR du des subnets Cloud"
    type                = string
}

variable "onprem_cidr" {
    description         = "CIDR du VPC Onprem"
    type                = string
}

variable "onprem_subnet_publica_id" {
    description         = "ID du subnet Onprem Public-A"
    type                = string
}

variable "server_vpn_instance_type" {
    description         = "Instance Type EC2 du Server VPN"
    type                = string
}

variable "onprem_vpn_eip" {
    description         = "Info Elastic IP pour le server VPN"
    type                = map(any)
}

variable "onprem_vpn_int_id" {
    description         = "ID de l'instance du serveur VPN"
    type                = string
}

variable "cloud_vpn_config" {
    description         = "Configurations du VPN Cloud"
    type                = map(any)
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
}
