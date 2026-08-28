################################################################################
# VPC
#
# Adaptateur pur, dans la region du service. Aucun client ne vit ici : ce VPC
# n'existe que pour heberger les ENI du service AWS et le NLB qui les expose.
#
# Le NLB ne repartit pas la charge. Un endpoint service est le seul objet que
# AWS accepte de partager entre regions, et un endpoint service exige un NLB.
# Il transforme un endpoint de service AWS, qui ne peut pas quitter sa region,
# en endpoint service client, qui le peut.
################################################################################

resource "aws_vpc" "this" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.resource_prefix}-vpc-endpoint-${var.service_region}"
    }
}

################################################################################
# Subnets
#
# Pas d'Internet Gateway, pas de NAT, pas d'attachement Tgw. La seule sortie de
# ce VPC est l'endpoint service.
################################################################################

resource "aws_subnet" "endpoint" {
    count = length(var.availability_zones)

    vpc_id            = aws_vpc.this.id
    cidr_block        = cidrsubnet(var.vpc_cidr, 1, count.index)
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.resource_prefix}-subnet-endpoint-${var.availability_zones[count.index]}"
    }
}

resource "aws_security_group" "endpoint" {
    name        = "${var.resource_prefix}-sg-endpoint-${var.service_region}"
    description = "Allow https inbound traffic from the NLB nodes"
    vpc_id      = aws_vpc.this.id

    # La preservation de l'IP client est desactivee par defaut pour un target
    # group de type ip en TCP : l'endpoint voit les adresses des noeuds NLB,
    # pas celles des clients. Le CIDR du VPC est donc a la fois suffisant et la
    # regle la plus stricte exprimable ici.
    ingress {
        description = "HTTPS depuis les noeuds NLB"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.resource_prefix}-sg-endpoint-${var.service_region}"
    }
}

################################################################################
# VPC Endpoints du service AWS a republier
################################################################################

resource "aws_vpc_endpoint" "service" {
    count             = length(var.services)
    vpc_id            = aws_vpc.this.id
    service_name      = "com.amazonaws.${var.service_region}.${var.services[count.index].name}"
    vpc_endpoint_type = "Interface"
    subnet_ids        = aws_subnet.endpoint[*].id

    security_group_ids = [
        aws_security_group.endpoint.id,
    ]

    # Desactive volontairement. La zone geree qu'AWS creerait ne resout que
    # dans ce VPC, et ce VPC n'a aucun client. Le nom est servi par la PHZ du
    # module vpc-endpoint, dans la region principale.
    private_dns_enabled = false

    # Adresses designees plutot que tirees par AWS : voir locals.tf. C'est ce
    # qui rend les cibles du NLB connues au plan et stables dans le temps.
    dynamic "subnet_configuration" {
        for_each = aws_subnet.endpoint

        content {
            subnet_id = subnet_configuration.value.id
            ipv4      = local.endpoint_ips["${count.index}-${subnet_configuration.key}"]
        }
    }

    tags = {
        Name = "${var.resource_prefix}-endpoint-${var.services[count.index].name}"
    }
}

################################################################################
# NLB - l'adaptateur
################################################################################

resource "aws_lb" "this" {
    count = length(var.services)

    name               = substr("${var.resource_prefix}-nlb-${var.services[count.index].name}", 0, 32)
    load_balancer_type = "network"
    internal           = true
    subnets            = aws_subnet.endpoint[*].id

    enable_cross_zone_load_balancing = true

    # Ne pas configurer de TCP idle timeout personnalise ici : PrivateLink
    # cross-region n'est pas supporte pour un NLB qui en porte un.

    lifecycle {
        # Trois pieges encodes en dur, parce que chacun produit une panne
        # silencieuse ou trompeuse plutot qu'une erreur claire.

        # 1. ID de zone ou PrivateLink cross-region ne fonctionne pas.
        precondition {
            condition = length(setintersection(
                toset(local.selected_zone_ids),
                toset(local.unsupported_zone_ids)
            )) == 0
            error_message = "Une des AZ choisies correspond a un ID de zone ou PrivateLink cross-region n'est pas supporte. Verifier avec describe-availability-zones dans CE compte."
        }

        # 2. AZ ou le service n'est pas offert. L'endpoint s'y creerait sans
        # erreur mais sans cible utile.
        precondition {
            condition     = length(setsubtract(toset(var.availability_zones), local.service_azs[count.index])) == 0
            error_message = "Le service ${var.services[count.index].name} n'est pas offert dans toutes les AZ demandees. Lire ServiceDetails[].AvailabilityZones."
        }

        # 3. Nom DNS deduit au lieu d'etre lu. Une zone privee au mauvais nom
        # est vivante, bien formee, et ne resout rien : le seul symptome est
        # que rien ne change.
        precondition {
            condition     = var.services[count.index].dns_name == local.service_private_dns[count.index]
            error_message = "dns_name configure (${var.services[count.index].dns_name}) different du nom DNS prive declare par le service. Lire ServiceDetails[].PrivateDnsName, ne jamais le deduire."
        }
    }

    tags = {
        Name = "${var.resource_prefix}-nlb-${var.services[count.index].name}"
    }
}

resource "aws_lb_target_group" "this" {
    count = length(var.services)

    name        = substr("${var.resource_prefix}-tg-${var.services[count.index].name}", 0, 32)
    vpc_id      = aws_vpc.this.id
    target_type = "ip"
    protocol    = "TCP"
    port        = 443

    health_check {
        # TCP et non HTTP. Un endpoint de service AWS n'expose aucun chemin de
        # sante : un health check HTTP declare malsaine toute cible
        # parfaitement fonctionnelle. Cette ligne fait la difference entre "le
        # motif marche" et "AWS l'interdit".
        protocol            = "TCP"
        port                = "traffic-port"
        interval            = 10
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = "${var.resource_prefix}-tg-${var.services[count.index].name}"
    }
}

resource "aws_lb_target_group_attachment" "this" {
    for_each = local.target_attachments

    target_group_arn  = aws_lb_target_group.this[each.value.service_index].arn
    target_id         = each.value.ip
    port              = 443
    availability_zone = var.availability_zones[each.value.az_index]
}

# Passthrough TCP, jamais de terminaison TLS. Le client negocie TLS avec le
# service AWS lui-meme : le certificat qui valide est celui du service et
# aucune autorite privee n'entre en jeu. Un listener TLS ici casserait a la
# fois la chaine de confiance et la signature SigV4.
resource "aws_lb_listener" "this" {
    count = length(var.services)

    load_balancer_arn = aws_lb.this[count.index].arn
    protocol          = "TCP"
    port              = 443

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.this[count.index].arn
    }
}

################################################################################
# Endpoint Services - publication vers la region principale
#
# Le role qui applique doit porter `vpce:AllowMultiRegion`, et aucune SCP ne
# doit le refuser, sinon la publication multi-region echoue. Cote consommateur
# la meme action est requise pour creer l'endpoint.
################################################################################

resource "aws_vpc_endpoint_service" "this" {
    count = length(var.services)

    acceptance_required        = false
    network_load_balancer_arns = [aws_lb.this[count.index].arn]

    # La region hote ne peut pas etre retiree de l'ensemble : l'omettre ferait
    # diverger l'etat a chaque plan. On liste donc les deux explicitement.
    supported_regions = [var.service_region, var.consumer_region]

    tags = {
        Name = "${var.resource_prefix}-endpoint-service-${var.services[count.index].name}"
    }
}

resource "aws_vpc_endpoint_service_allowed_principal" "this" {
    count = length(var.services)

    vpc_endpoint_service_id = aws_vpc_endpoint_service.this[count.index].id
    principal_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}
