variable "vpc_perimetre_tgwattach_id" {
    description         = "ID Tgw attachement du VPC Perimetre"
    type                = string
}

variable "tgw_association_route_table_ids" {
    description         = "Liste des ID des table de routage Tgw a associer au VPC"
    type                = list(string)
}

variable "tgw_propagation_route_table_ids" {
    description         = "Liste des ID des table de routage Tgw ou propager les CIDRs du VPC"
    type                = list(string)
}

variable "tgw_rt_shared_id" {
    description         = "ID de la table de routage Shared du Tgw"
    type                = string
}

variable "tgw_rt_segregated_id" {
    description         = "ID de la table de routage Segregated du Tgw"
    type                = string
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
}