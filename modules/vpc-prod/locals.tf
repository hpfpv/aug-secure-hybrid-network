locals {
  subnet_to_share = [aws_subnet.app_a.arn, aws_subnet.app_b.arn]
}