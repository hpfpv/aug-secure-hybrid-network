data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-gp2"]
  }
}
# al2023-ami-2023.1.20230809.0-kernel-6.1-x86_64