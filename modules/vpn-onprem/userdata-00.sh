#!/bin/bash
echo "Configuring Strongswan..."

# Install Strongswan
sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install -y strongswan
sudo yum install -y bird

/etc/bird.conf#######

# Create VPN configuration file - Default
sudo tee -a /etc/strongswan/ipsec.conf <<EOL
conn %default
    left=${data.aws_network_interface.onprem_vpn_int.private_ip}
    leftsubnet=${var.onprem_cidr}
    dpdaction=restart
    authby=psk

EOL

# Create VPN configuration file - Tunnel 1
sudo tee -a /etc/strongswan/ipsec.conf <<EOL
conn ${local.cloud_vpn_name}-t1
    right=${var.cloud_vpn_config.tunnel1_address}
    rightsubnet=${var.cloud_cidr}
    auto=start

EOL

# Create Secrets File - Tunnel 1
sudo tee -a /etc/strongswan/ipsec.secrets <<EOL
${data.aws_network_interface.onprem_vpn_int.private_ip} ${var.cloud_vpn_config.tunnel1_address} : PSK ${var.cloud_vpn_config.tunnel1_preshared_key}
EOL

# Create VPN configuration file - Tunnel 2
sudo tee -a /etc/strongswan/ipsec.conf <<EOL
conn ${local.cloud_vpn_name}-t2
    right=${var.cloud_vpn_config.tunnel2_address}
    rightsubnet=${var.cloud_cidr}
    auto=start

EOL

# Create Secrets File - Tunnel 2
sudo tee -a /etc/strongswan/ipsec.secrets <<EOL
${data.aws_network_interface.onprem_vpn_int.private_ip} ${var.cloud_vpn_config.tunnel2_address} : PSK ${var.cloud_vpn_config.tunnel2_preshared_key}
EOL

# Enable BGP routing
VPN_TUNNEL_1=${local.cloud_vpn_name}-t1
VPN_TUNNEL_2=${local.cloud_vpn_name}-t2
LOCAL_INSIDE_1=${var.cloud_vpn_config.tunnel1_cgw_inside_address}/30
REMOTE_INSIDE_1=${var.cloud_vpn_config.tunnel1_vgw_inside_address}/30
LOCAL_INSIDE_2=${var.cloud_vpn_config.tunnel2_cgw_inside_address}/30
REMOTE_INSIDE_2=${var.cloud_vpn_config.tunnel2_vgw_inside_address}/30

sudo aws s3 cp s3://${aws_s3_bucket.userdata.bucket}/vpn/ipsec-vti.sh /etc/strongswan/ipsec-vti.sh
sudo chmod +x /etc/strongswan/ipsec-vti.sh
/etc/strongswan/ipsec-vti.sh

# Start Strongswan
systemctl enable strongswan && 
systemctl start  strongswan

# Set Strongswan to start on boot
sudo chkconfig strongswan on

# Enable IP Forwarding
sudo tee -a /etc/sysctl.conf <<EOL
net.ipv4.ip_forward=1
net.ipv4.conf.eth0.disable_xfrm=1
net.ipv4.conf.eth0.disable_policy=1
EOL

sudo sysctl -p

echo "Strongswan configuration completed."