output "vpc_id" {
  description   = "ID du VPC Dev"
  value         = aws_vpc.dev.id
}

output "tgwattach_id" {
  description   = "ID de l'attachement Tgw du VPC Dev"
  value         = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}