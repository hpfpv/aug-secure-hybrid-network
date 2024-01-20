output "vpc_id" {
  description   = "ID du VPC Endpoint"
  value         = aws_vpc.endpoint.id
}

output "tgwattach_id" {
  description   = "ID de l'attachement Tgw du VPC Endpoint"
  value         = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}

output "central_endpoints" {
  description   = "Liste des info des VPC endpoints deployes"
  value         = local.endpoints_dns
}

output "central_endpoints_phz" {
  description = "Liste des ID des PHZ"
  value = aws_route53_zone.phz[*].zone_id
}
