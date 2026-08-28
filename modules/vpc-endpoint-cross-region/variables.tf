variable "service_region" {
    description         = "Region ou vit le service AWS, celle que la region principale ne peut pas joindre en prive"
    type                = string
}

variable "consumer_region" {
    description         = "Region principale, celle qui consommera l'endpoint service"
    type                = string
}

variable "services" {
    description         = <<-EOT
        Services a republier. Le nom DNS est explicite et jamais deduit : tous
        les services ne repondent pas sur <service>.<region>.amazonaws.com,
        plusieurs services recents utilisent .api.aws. Le deduire produit une
        zone valide qui ne resout rien.

          aws ec2 describe-vpc-endpoint-services --region <service_region> \
            --filters Name=service-name,Values=com.amazonaws.<service_region>.<name> \
            --query 'ServiceDetails[].PrivateDnsName'
    EOT
    type                = list(object({
        name     = string
        dns_name = string
    }))
}

variable "vpc_cidr" {
    description         = <<-EOT
        CIDR du VPC dans la region du service. Il ne contient que des ENI
        d'endpoint et des noeuds NLB : un /26 suffit.

        A choisir hors de toute plage routee ou blackholee par la landing zone.
        Ce VPC n'est jamais appaire ni attache a un Tgw : une plage
        volontairement etrangere rend evident dans les logs qu'il ne fait pas
        partie du reseau route.
    EOT
    type                = string
    default             = "192.168.240.0/26"

    validation {
        condition     = tonumber(split("/", var.vpc_cidr)[1]) <= 26
        error_message = "Le VPC est decoupe en deux subnets et les adresses d'endpoint sont designees a l'offset 10 : /26 au maximum."
    }
}

variable "availability_zones" {
    description         = <<-EOT
        Exactement deux AZ dans la region du service, par nom.

        Deux contraintes se croisent. Le service n'est pas offert dans toutes
        les AZ, et PrivateLink cross-region ne fonctionne pas dans quelques ID
        de zone. Les noms de zone pointent vers des ID differents selon le
        compte : la precondition sur le NLB verifie les ID dans CE compte.
    EOT
    type                = list(string)

    validation {
        condition     = length(var.availability_zones) == 2
        error_message = "PrivateLink cross-region exige le NLB dans au moins deux AZ."
    }
}

variable "resource_prefix" {
    description         = "Prefixe pour le nom des ressources"
    type                = string
}
