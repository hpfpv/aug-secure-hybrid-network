variable "cgw_bgp_asn" {
    description         = "BGP ASN du Customer Gateway"
    type                = number
}

variable "cgw_ip" {
    description         = "IP publique du Customer Gateway"
    type                = string
}

variable "tgw_principal_id" {
    description         = "ID du Transit Gateway Principal"
    type                = string
}

variable "tgw_association_route_table_ids" {
    description         = "Liste des ID des table de routage Tgw a associer au VPN"
    type                = list(string)
}

variable "tgw_propagation_route_table_ids" {
    description         = "Liste des ID des table de routage Tgw ou propager les CIDRs du VPN (Onprem)"
    type                = list(string)
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
}