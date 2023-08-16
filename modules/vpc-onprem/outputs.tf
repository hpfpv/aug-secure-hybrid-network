output "vpc_id" {
  description   = "ID du VPC Onprem"
  value         = aws_vpc.onprem.id
}

output "vpc_cidr" {
  description   = "CIDR du VPC Onprem"
  value         = aws_vpc.onprem.cidr_block
}

output "subnet_privatea_id" {
  description   = "ID du Subnet Private-A"
  value         = aws_subnet.private_a.id
}

output "subnet_publica_id" {
  description   = "ID du Subnet Public-A"
  value         = aws_subnet.public_a.id
}

output "onprem_vpn_eip" {
  description   = "Info Elastic IP pour le server VPN"
  value         = {
    id                = aws_eip.onprem_vpn_ip.id
    private_ip        = aws_eip.onprem_vpn_ip.private_ip
    public_ip         = aws_eip.onprem_vpn_ip.public_ip
  }
}

output "onprem_vpn_int_id" {
  description   = "ID de l'Interface privee du Server VPN"
  value         = aws_network_interface.vpn_server_private_interface.id
}