locals {
    endpoints_dns = {
        for dns in flatten(aws_vpc_endpoint.service[*].dns_entry) :
        dns.dns_name => dns.hosted_zone_id
    }

    endpoints_zone_ids = {
        for key, value in local.endpoints_dns :
        key => value
        if length(regexall(".${var.region}.amazonaws.com", key)) > 0 ? true : false
    }
  }