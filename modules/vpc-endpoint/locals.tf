locals {
    endpoints_dns = {
        for dns in flatten(aws_vpc_endpoint.service[*].dns_entry) :
        dns.dns_name => dns.hosted_zone_id
    }

    endpoints_zone_ids = {
        for key, value in local.endpoints_dns :
        key => value
        if length(regexall(".${var.region}.amazonaws.com", key)) > 0 ? true : false
    }

    # Un endpoint publie une entree DNS regionale plus une par AZ. En
    # cross-region seule l'entree REGIONALE est utilisable : les noms zonaux
    # epinglent une AZ.
    #
    # Le nom zonal est le nom regional avec "-<zone>" insere dans le premier
    # label. Le nom regional est donc toujours le plus court des trois. C'est
    # la seule regle qui tienne : le format observe porte un suffixe apres
    # l'ID d'endpoint
    #   vpce-093437533c2c03a70-vzu4gzx0.bedrock-mantle.us-east-1.vpce.amazonaws.com
    #   vpce-093437533c2c03a70-vzu4gzx0-us-east-1c.bedrock-mantle....
    # ce qui casse toute selection basee sur le nombre de morceaux, et rien ne
    # garantit qu'AWS ecrive un nom d'AZ plutot qu'un ID d'AZ dans le nom zonal,
    # ce qui casse toute selection basee sur une regex de zone.
    cross_region_dns = [
        for ep in aws_vpc_endpoint.cross_region :
        one([
            for e in ep.dns_entry :
            e if length(e.dns_name) == min([for f in ep.dns_entry : length(f.dns_name)]...)
        ])
    ]
}
