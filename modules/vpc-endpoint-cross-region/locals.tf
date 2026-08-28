locals {
    # AZ ou PrivateLink cross-region n'est pas supporte, par ID de zone.
    # https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-share-your-services.html
    unsupported_zone_ids = ["use1-az3", "usw1-az2", "apne1-az3", "apne2-az2", "apne2-az4"]

    selected_zone_ids = data.aws_availability_zones.this.zone_ids

    # AZ ou le service est reellement offert, par service. Rien ne garantit
    # qu'il couvre toute la region : bedrock-mantle n'est offert que dans
    # trois AZ d'us-east-1 sur six.
    service_azs = [for d in data.aws_vpc_endpoint_service.target : toset(d.availability_zones)]

    # Nom DNS prive tel que le service le declare, pour comparaison avec ce
    # qui est configure.
    service_private_dns = [for d in data.aws_vpc_endpoint_service.target : d.private_dns_name]

    # Adresses designees pour les ENI d'endpoint, une par (service, subnet).
    #
    # On choisit les adresses au lieu de les laisser AWS les tirer, pour deux
    # raisons. D'abord elles deviennent connues au plan : les cibles du NLB
    # sont ecrites en dur au lieu d'etre lues via une data source, ce qui
    # evite un for_each sur une valeur connue seulement apres apply et donc un
    # apply en deux passes. Ensuite elles sont stables : une ENI d'endpoint
    # remplacee par AWS reprend la meme adresse au lieu d'en tirer une autre et
    # de laisser le target group pointer dans le vide.
    #
    # Offset 10 : les quatre premieres adresses et la derniere d'un subnet sont
    # reservees par AWS et ne peuvent pas etre designees.
    endpoint_ips = {
        for pair in setproduct(range(length(var.services)), range(length(var.availability_zones))) :
        "${pair[0]}-${pair[1]}" => cidrhost(cidrsubnet(var.vpc_cidr, 1, pair[1]), 10 + pair[0])
    }

    # Une attache NLB par couple (service, AZ). Cles et valeurs statiques.
    target_attachments = {
        for pair in setproduct(range(length(var.services)), range(length(var.availability_zones))) :
        "${pair[0]}-${pair[1]}" => {
            service_index = pair[0]
            az_index      = pair[1]
            ip            = cidrhost(cidrsubnet(var.vpc_cidr, 1, pair[1]), 10 + pair[0])
        }
    }

    # Contrat consomme par le module vpc-endpoint : tout ce qu'il lui faut pour
    # creer l'endpoint consommateur et la PHZ correspondante.
    endpoint_services = [
        for i, svc in var.services : {
            name           = svc.name
            dns_name       = svc.dns_name
            service_name   = aws_vpc_endpoint_service.this[i].service_name
            service_region = var.service_region
        }
    ]
}
