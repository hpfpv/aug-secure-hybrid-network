variable "ram_principals" {
    description         = "Une liste de principals avec lesquels partager TGW. Les valeurs possibles sont un ID de compte AWS, un ARN d'organisation AWS Organizations ou un ARN d'unité d'organisation AWS Organizations"
    type                = list(string)
}

variable "tgw_bgp_asn" {
    description         = "BGP ASN du Transit Gateway"
    type                = number
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
}