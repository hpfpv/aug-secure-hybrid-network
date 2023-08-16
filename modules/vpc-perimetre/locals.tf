locals {
  nfw_endpoint_ids = {
    for attachment in flatten(aws_networkfirewall_firewall.perimetre.firewall_status[0].sync_states[*]) :
    attachment.availability_zone => attachment.attachment[0].endpoint_id
  }
}