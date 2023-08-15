resource "aws_instance" "server_vpn" {
    ami           = local.ami
    instance_type = var.server_vpn_instance_type

    network_interface {
        network_interface_id = aws_network_interface.vpn_server_private_interface.id
        device_index         = 0
    }

    user_data = <<-EOF
                #!/bin/bash
                echo "Configuring OpenSwan..."
                # Add your OpenSwan configuration commands here
                EOF
}