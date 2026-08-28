data "aws_caller_identity" "current" {}

# Les noms d'AZ pointent vers des ID physiques differents d'un compte a
# l'autre. La verification des ID exclus doit donc se faire ici, dans le
# compte qui deploie.
data "aws_availability_zones" "this" {
    state = "available"

    filter {
        name   = "zone-name"
        values = var.availability_zones
    }
}

# Le service lui-meme, interroge plutot que suppose. Il fournit les deux
# choses qu'on ne doit jamais deviner : les AZ ou il est reellement offert, et
# son vrai nom DNS prive. Les preconditions sur le NLB comparent la
# configuration a ces valeurs.
data "aws_vpc_endpoint_service" "target" {
    count = length(var.services)

    service_name = "com.amazonaws.${var.service_region}.${var.services[count.index].name}"
}
