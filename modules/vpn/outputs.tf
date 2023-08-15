output "vpn_connection_attributes" {
  value = {
    arn                              = aws_vpn_connection.vpn.arn
    id                               = aws_vpn_connection.vpn.id
    customer_gateway_configuration   = aws_vpn_connection.vpn.customer_gateway_configuration
    customer_gateway_id              = aws_vpn_connection.vpn.customer_gateway_id
    static_routes_only               = aws_vpn_connection.vpn.static_routes_only
    transit_gateway_attachment_id    = aws_vpn_connection.vpn.transit_gateway_attachment_id
    tunnel1_address                  = aws_vpn_connection.vpn.tunnel1_address
    tunnel1_cgw_inside_address       = aws_vpn_connection.vpn.tunnel1_cgw_inside_address
    tunnel1_vgw_inside_address       = aws_vpn_connection.vpn.tunnel1_vgw_inside_address
    tunnel1_preshared_key            = aws_vpn_connection.vpn.tunnel1_preshared_key 
    tunnel2_address                  = aws_vpn_connection.vpn.tunnel2_address
    tunnel2_cgw_inside_address       = aws_vpn_connection.vpn.tunnel2_cgw_inside_address
    tunnel2_vgw_inside_address       = aws_vpn_connection.vpn.tunnel2_vgw_inside_address
    tunnel2_preshared_key            = aws_vpn_connection.vpn.tunnel2_preshared_key
  }
}