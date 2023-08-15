output "vpc_id" {
  description   = "ID du VPC Endpoint"
  value         = aws_vpc.endpoint.id
}

output "tgwattach_id" {
  description   = "ID de l'attachement Tgw du VPC Endpoint"
  value         = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}