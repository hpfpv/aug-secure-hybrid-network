################################################################################
# IAM Instance Profile
################################################################################

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name              = "${var.resource_prefix}-ssm-instance-profile"
  role              = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
  name                      = "${var.resource_prefix}-ssm-instance-profile"
  managed_policy_arns       = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy", "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy", aws_iam_policy.s3_userdata_policy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "s3_userdata_policy" {
  name        = "${var.resource_prefix}-s3-userdata-policy"
  description = "IAM policy to access an S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.userdata.bucket}/*",  
          "arn:aws:s3:::${aws_s3_bucket.userdata.bucket}",      
        ],
      },
    ],
  })
}

# resource "aws_iam_role_policy_attachment" "s3_userdata_policy_attachment" {
#   role                  = aws_iam_role.ssm_role.name
#   policy_arn            = aws_iam_policy.s3_userdata_policy.arn
# }

################################################################################
# Instance EC2
################################################################################

resource "aws_instance" "server_vpn" {
    depends_on = [ aws_s3_bucket.userdata ]

    ami                         = data.aws_ami.amazon_linux_2.id
    instance_type               = var.server_vpn_instance_type
    iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name

    root_block_device {
        volume_type             = "gp3"
        volume_size             = "20" 
    }

    network_interface {
        network_interface_id    = var.onprem_vpn_int_id
        device_index            = 0
    }

    user_data = <<-EOF
        #!/bin/bash
        echo "Configuring Strongswan..."

        # Install Strongswan
        sudo yum update -y
        sudo amazon-linux-extras install epel -y
        sudo yum install -y strongswan
        sudo yum install -y bird
        
        # Create BIRD configuration file
        sudo tee /etc/bird.conf <<EOL
        router id ${data.aws_network_interface.onprem_vpn_int.private_ip};
        protocol device {
            scan time 10;
        }
        protocol kernel {
            learn;
            merge paths on; # For ECMP
            export filter { 
                krt_prefsrc = ${data.aws_network_interface.onprem_vpn_int.private_ip};
                accept;
            };
            import all; 
        }
        protocol static {
            route ${var.onprem_cidr} recursive ${data.aws_network_interface.onprem_vpn_int.private_ip};
        }
        protocol bgp Tunnel1 {
            description "${local.cloud_vpn_name}-t1";
            local ${var.cloud_vpn_config.tunnel1_cgw_inside_address} as ${var.cgw_bgp_asn};
            neighbor ${var.cloud_vpn_config.tunnel1_vgw_inside_address} as ${var.tgw_bgp_asn};
            import all;
            export all;
        }
        protocol bgp Tunnel2 {
            description "${local.cloud_vpn_name}-t2";
            local ${var.cloud_vpn_config.tunnel2_cgw_inside_address} as ${var.cgw_bgp_asn};
            neighbor ${var.cloud_vpn_config.tunnel2_vgw_inside_address} as ${var.tgw_bgp_asn};
            import all;
            export all;
        }
        EOL

        sudo sed -i 's/# install_routes = yes/install_routes = no/' /etc/strongswan/strongswan.d/charon.conf

        # Copy the necessary scripts from s3
        sudo aws s3 cp s3://${aws_s3_bucket.userdata.bucket}/vpn/ipsec-vti.sh /etc/strongswan/ipsec-vti.sh
        sudo chmod +x /etc/strongswan/ipsec-vti.sh
        /etc/strongswan/ipsec-vti.sh

        # Create VPN configuration file - Default
        sudo tee -a /etc/strongswan/ipsec.conf <<EOL
        conn %default
            left=${data.aws_network_interface.onprem_vpn_int.private_ip}
            leftsubnet=0.0.0.0/0
            dpdaction=restart
            authby=psk
            mark=%unique
        EOL

        # Create VPN configuration file - Tunnel 1
        sudo tee -a /etc/strongswan/ipsec.conf <<EOL
        conn ${local.cloud_vpn_name}-t1
            leftupdown="/etc/strongswan/ipsec-vti.sh 0 ${var.cloud_vpn_config.tunnel1_vgw_inside_address}/30 ${var.cloud_vpn_config.tunnel1_cgw_inside_address}/30"
            right=${var.cloud_vpn_config.tunnel1_address}
            rightsubnet=0.0.0.0/0
            auto=start
        EOL

        # Create Secrets File - Tunnel 1
        sudo tee -a /etc/strongswan/ipsec.secrets <<EOL
        ${var.cloud_vpn_config.tunnel1_address} : PSK "${var.cloud_vpn_config.tunnel1_preshared_key}"
        EOL

        # Create VPN configuration file - Tunnel 2
        sudo tee -a /etc/strongswan/ipsec.conf <<EOL
        conn ${local.cloud_vpn_name}-t2
            leftupdown="/etc/strongswan/ipsec-vti.sh 0 ${var.cloud_vpn_config.tunnel2_vgw_inside_address}/30 ${var.cloud_vpn_config.tunnel2_cgw_inside_address}/30"
            right=${var.cloud_vpn_config.tunnel2_address}
            rightsubnet=0.0.0.0/0
            auto=start
        EOL

        # Create Secrets File - Tunnel 2
        sudo tee -a /etc/strongswan/ipsec.secrets <<EOL
        ${var.cloud_vpn_config.tunnel2_address} : PSK "${var.cloud_vpn_config.tunnel2_preshared_key}"
        EOL

        # Start Strongswan and Bird
        systemctl start bird
        systemctl start strongswan

        systemctl enable bird
        systemctl enable strongswan

        echo "Strongswan configuration completed."
    EOF
    
    tags = {
      Name = "${var.resource_prefix}-onprem-server-vpn"
  }
}