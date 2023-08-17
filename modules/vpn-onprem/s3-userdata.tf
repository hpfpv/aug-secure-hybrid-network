resource "aws_s3_bucket" "userdata" {
  bucket                        = "${var.resource_prefix}-vpn-${data.aws_caller_identity.current.account_id}"
  force_destroy                 = true
}

resource "aws_s3_object" "userdata_sh" {
  bucket = aws_s3_bucket.userdata.bucket
  key    = "vpn/ipsec-vti.sh"
  source = "./modules/vpn-onprem/ipsec-vti.sh"
}



