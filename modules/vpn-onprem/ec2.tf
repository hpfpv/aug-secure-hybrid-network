################################################################################
# Instance EC2
################################################################################

resource "aws_instance" "server_vpn" {
    ami                         = data.aws_ami.amazon_linux_2.id
    instance_type               = var.server_vpn_instance_type

    network_interface {
        network_interface_id    = var.onprem_vpn_int_id
        device_index            = 0
    }

    user_data = <<-EOF
            #!/bin/bash
            echo "Configuring OpenSwan..."

            # Install Openswan
            sudo yum install -y openswan

            # Edit ipsec.conf
            echo 'include /etc/ipsec.d/*.conf' | sudo tee -a /etc/ipsec.conf

            # Create VPN configuration file - Tunnel 1
            sudo tee /etc/ipsec.d/${local.cloud_vpn_name}-t1.conf <<EOL
            conn ${local.cloud_vpn_name}-t1
            type=tunnel
            authby=secret
            auto=start
            left=%defaultroute
            leftid=${var.onprem_vpn_eip.public_ip}
            leftsubnet=${var.onprem_cidr}
            leftnexthop=%defaultroute
            right=${var.cloud_vpn_config.tunnel1_address}
            rightsubnet=${var.cloud_cidr}
            pfs=yes
            ike=aes128-sha1;modp1024
            ikelifetime=28800s
            esp=aes128-sha1;modp1024
            salifetime=28800s
            EOL

            # Create Secrets File - Tunnel 1
            sudo tee /etc/ipsec.d/${local.cloud_vpn_name}-t1.secrets <<EOL
            ${var.onprem_vpn_eip.public_ip} ${var.cloud_vpn_config.tunnel1_address} : PSK "${var.cloud_vpn_config.tunnel1_preshared_key}"
            EOL

            # Create VPN configuration file - Tunnel 2
            sudo tee /etc/ipsec.d/${local.cloud_vpn_name}-t2.conf <<EOL
            conn ${local.cloud_vpn_name}-t2
            type=tunnel
            authby=secret
            auto=start
            left=%defaultroute
            leftid=${var.onprem_vpn_eip.public_ip}
            leftsubnet=${var.onprem_cidr}
            leftnexthop=%defaultroute
            right=${var.cloud_vpn_config.tunnel2_address}
            rightsubnet=${var.cloud_cidr}
            pfs=yes
            ike=aes128-sha1;modp1024
            ikelifetime=28800s
            esp=aes128-sha1;modp1024
            salifetime=28800s
            EOL

            # Create Secrets File - Tunnel 2
            sudo tee /etc/ipsec.d/${local.cloud_vpn_name}-t2.secrets <<EOL
            ${var.onprem_vpn_eip.public_ip} ${var.cloud_vpn_config.tunnel2_address} : PSK "${var.cloud_vpn_config.tunnel2_preshared_key}"
            EOL

            # Start Openswan
            sudo service ipsec start

            # Set Openswan to start on boot
            sudo chkconfig ipsec on

            # Enable IP Forwarding
            sudo sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
            sudo sysctl -p

            echo "OpenSwan configuration completed."
            EOF
    
    tags = {
      Name = "${var.resource_prefix}-onprem-server-vpn"
  }
}