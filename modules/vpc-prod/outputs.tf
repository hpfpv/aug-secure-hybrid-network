output "vpc_id" {
  description   = "ID du VPC Prod"
  value         = aws_vpc.prod.id
}

output "tgwattach_id" {
  description   = "ID de l'attachement Tgw du VPC Prod"
  value         = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}