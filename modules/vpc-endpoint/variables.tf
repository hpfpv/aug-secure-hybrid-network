variable "vpc_cidr" {
    description         = "CIDR du VPC"
    type                = string
}

variable "subnet_tgwattacha_cidr" {
    description         = "CIDR du subnet Tgwattach-A"
    type                = string
}

variable "subnet_tgwattachb_cidr" {
    description         = "CIDR du subnet Tgwattach-B"
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

variable "tgw_principal_id" {
    description         = "ID du Transit Gateway Principal"
    type                = string
}

variable "services" {
  type    = list(string)
  default = ["ec2", "ssm", "ec2messages", "ssmmessages", "kms", "logs", "cloudformation", "secretsmanager", "monitoring"]
}

variable "tgw_association_route_table_ids" {
    description         = "Liste des ID des table de routage Tgw a associer au VPC"
    type                = list(string)
}

variable "tgw_propagation_route_table_ids" {
    description         = "Liste des ID des table de routage Tgw ou propager les CIDRs du VPC"
    type                = list(string)
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
}

variable "region" {
  description           = "Region AWS pour la creation des ressources"
  type                  = string
}