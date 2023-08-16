variable "vpc_cidr" {
    description         = "CIDR du VPC"
    type                = string
}

variable "subnet_tgwattacha_cidr" {
    description         = "CIDR du subnet Tgwattach-A"
    type                = string
}

variable "subnet_tgwattachb_cidr" {
    description         = "CIDR du subnet Tgwattach-A"
    type                = string
}

variable "subnet_nfwa_cidr" {
    description         = "CIDR du subnet Nfw-A"
    type                = string
}

variable "subnet_nfwb_cidr" {
    description         = "CIDR du subnet Nfw-B"
    type                = string
}

variable "subnet_nata_cidr" {
    description         = "CIDR du subnet Nat-A"
    type                = string
}

variable "subnet_natb_cidr" {
    description         = "CIDR du subnet Nat-B"
    type                = string
}

variable "tgw_principal_id" {
    description         = "ID du Transit Gateway Principal"
    type                = string
}

# variable "tgw_association_route_table_ids" {
#     description         = "Liste des ID des table de routage Tgw a associer au VPC"
#     type                = list(string)
# }

# variable "tgw_propagation_route_table_ids" {
#     description         = "Liste des ID des table de routage Tgw ou propager les CIDRs du VPC"
#     type                = list(string)
# }

# variable "tgw_rt_shared_id" {
#     description         = "ID de la table de routage Shared du Tgw"
#     type                = string
# }

# variable "tgw_rt_segregated_id" {
#     description         = "ID de la table de routage Segregated du Tgw"
#     type                = string
# }

variable "ram_tgw_resource_share_arns" {
    description         = "Arn du partage RAM du Transit Gateway"
    type                = list(string)
}

variable "use_central_endpoints" {
    description         = "True or False si le VPC utilise les VPC Endpoints deployes dans le VPC Endpoint"
    type                = bool
}

variable "central_endpoints_phz" {
    description         = "Map des central endpoints avec les ID private Hosted Zone"
    type                = list(string)
    default             = []
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
}
