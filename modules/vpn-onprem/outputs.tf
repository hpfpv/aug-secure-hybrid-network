# output "onprem_vpn_eip" {
#   description   = "Info Elastic IP pour le server VPN"
#   value         = {
#     id                = aws_eip.onprem_vpn_ip.id
#     private_ip        = aws_eip.onprem_vpn_ip.private_ip
#     public_ip         = aws_eip.onprem_vpn_ip.public_ip
#   }
# }

output "vpn_server_instance_id" {
  description = "ID de l'instance du serveur VPN"
  value       = aws_instance.server_vpn.id
}

