output "endpoint_services" {
    description = "Contrat consomme par le module vpc-endpoint : nom du service, nom DNS reel et region"
    value       = local.endpoint_services
}

output "service_endpoint_ips" {
    description = "Adresses designees des ENI d'endpoint, telles qu'enregistrees dans le NLB"
    value       = local.endpoint_ips
}
