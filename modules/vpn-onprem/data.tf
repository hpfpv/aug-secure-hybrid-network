data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-gp2"]
  }
}

data "aws_network_interface" "onprem_vpn_int" {
  id = var.onprem_vpn_int_id
}

# al2023-ami-2023.1.20230809.0-kernel-6.1-x86_64