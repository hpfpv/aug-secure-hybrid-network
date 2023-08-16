resource "aws_networkfirewall_firewall_policy" "perimetre" {
  name = "${var.resource_prefix}-nfw-policy-perimetre"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
    # stateless_rule_group_reference {
    #   priority     = 1
    #   resource_arn = aws_networkfirewall_rule_group.example.arn
    # }
  }

  tags = {
    Name = "${var.resource_prefix}-nfw-policy-perimetre"
  }
}

resource "aws_networkfirewall_firewall" "perimetre" {
  name                = "${var.resource_prefix}-nfw-perimetre"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.perimetre.arn
  vpc_id              = aws_vpc.perimetre.id

  subnet_mapping {
    subnet_id = aws_subnet.nfw_a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.nfw_b.id
  }

  tags = {
    Name = "${var.resource_prefix}-nfw-perimetre"
  }
}

resource "aws_cloudwatch_log_group" "perimetre" {
  name                  = "/aws/network-firewall/${var.resource_prefix}-nfw-perimetre"
  retention_in_days     = 14
  tags = {
    Name = "/aws/network-firewall/${var.resource_prefix}-nfw-perimetre"
  }
}

resource "aws_networkfirewall_logging_configuration" "perimetre" {
  firewall_arn = aws_networkfirewall_firewall.perimetre.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.perimetre.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}