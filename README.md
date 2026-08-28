# Réseau Hybride Sécuritaire et évolutif AWS

![Architecture](docs/diagram.png)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tgw_principal"></a> [tgw\_principal](#module\_tgw\_principal) | ./modules/tgw | n/a |
| <a name="module_tgw_route_0"></a> [tgw\_route\_0](#module\_tgw\_route\_0) | ./modules/tgw-route-0 | n/a |
| <a name="module_vpc_dev"></a> [vpc\_dev](#module\_vpc\_dev) | ./modules/vpc-dev | n/a |
| <a name="module_vpc_endpoint"></a> [vpc\_endpoint](#module\_vpc\_endpoint) | ./modules/vpc-endpoint | n/a |
| <a name="module_vpc_endpoint_cross_region"></a> [vpc\_endpoint\_cross\_region](#module\_vpc\_endpoint\_cross\_region) | ./modules/vpc-endpoint-cross-region | n/a |
| <a name="module_vpc_onprem"></a> [vpc\_onprem](#module\_vpc\_onprem) | ./modules/vpc-onprem | n/a |
| <a name="module_vpc_perimetre"></a> [vpc\_perimetre](#module\_vpc\_perimetre) | ./modules/vpc-perimetre | n/a |
| <a name="module_vpc_prod"></a> [vpc\_prod](#module\_vpc\_prod) | ./modules/vpc-prod | n/a |
| <a name="module_vpn_cloud"></a> [vpn\_cloud](#module\_vpn\_cloud) | ./modules/vpn-cloud | n/a |
| <a name="module_vpn_onprem"></a> [vpn\_onprem](#module\_vpn\_onprem) | ./modules/vpn-onprem | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_network"></a> [assume\_role\_network](#input\_assume\_role\_network) | Arn du role IAM a assumer pour deployer les ressources dans le compte Network (sandbox01) | `string` | n/a | yes |
| <a name="input_assume_role_perimetre"></a> [assume\_role\_perimetre](#input\_assume\_role\_perimetre) | Arn du role IAM a assumer pour deployer les ressources dans le compte Perimetre (sandbox02) | `string` | n/a | yes |
| <a name="input_cgw_bgp_asn"></a> [cgw\_bgp\_asn](#input\_cgw\_bgp\_asn) | BGP ASN du Customer Gateway | `number` | n/a | yes |
| <a name="input_cloud_cidr"></a> [cloud\_cidr](#input\_cloud\_cidr) | CIDR du Cloud | `string` | n/a | yes |
| <a name="input_cross_region_services"></a> [cross\_region\_services](#input\_cross\_region\_services) | Services a republier depuis service\_region. Le nom DNS est explicite, jamais deduit | <pre>list(object({<br>      name     = string<br>      dns_name = string<br>    }))</pre> | <pre>[<br>  {<br>    "dns_name": "bedrock-mantle.us-east-1.api.aws",<br>    "name": "bedrock-mantle"<br>  }<br>]</pre> | no |
| <a name="input_endpoint_service_region_azs"></a> [endpoint\_service\_region\_azs](#input\_endpoint\_service\_region\_azs) | Deux AZ dans service\_region. Verifier l'offre du service et les ID de zone dans le compte cible | `list(string)` | <pre>[<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_onprem_region"></a> [onprem\_region](#input\_onprem\_region) | Region AWS pour la creation des ressources On Prem | `string` | n/a | yes |
| <a name="input_ram_principals"></a> [ram\_principals](#input\_ram\_principals) | Une liste de principals avec lesquels partager TGW. Les valeurs possibles sont un ID de compte AWS, un ARN d'organisation AWS Organizations ou un ARN d'unité d'organisation AWS Organizations | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region AWS pour la creation des ressources | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefixe pour le nom des ressources | `string` | `"aug-sec-network"` | no |
| <a name="input_server_vpn_instance_type"></a> [server\_vpn\_instance\_type](#input\_server\_vpn\_instance\_type) | Type de l'instance du server VPN | `string` | n/a | yes |
| <a name="input_server_vpn_private_ips"></a> [server\_vpn\_private\_ips](#input\_server\_vpn\_private\_ips) | Liste des IP Privees du server VPN dans le subnet Public-A | `list(string)` | n/a | yes |
| <a name="input_service_region"></a> [service\_region](#input\_service\_region) | Region ou vit le service AWS inaccessible en prive depuis la region principale | `string` | `"us-east-1"` | no |
| <a name="input_subnet_dev_appa_cidr"></a> [subnet\_dev\_appa\_cidr](#input\_subnet\_dev\_appa\_cidr) | CIDR du subnet Dev-App-A | `string` | n/a | yes |
| <a name="input_subnet_dev_appb_cidr"></a> [subnet\_dev\_appb\_cidr](#input\_subnet\_dev\_appb\_cidr) | CIDR du subnet Dev-App-B | `string` | n/a | yes |
| <a name="input_subnet_dev_tgwattacha_cidr"></a> [subnet\_dev\_tgwattacha\_cidr](#input\_subnet\_dev\_tgwattacha\_cidr) | CIDR du subnet Dev-Tgwattach-A | `string` | n/a | yes |
| <a name="input_subnet_dev_tgwattachb_cidr"></a> [subnet\_dev\_tgwattachb\_cidr](#input\_subnet\_dev\_tgwattachb\_cidr) | CIDR du subnet Dev-Tgwattach-B | `string` | n/a | yes |
| <a name="input_subnet_endpoint_tgwattacha_cidr"></a> [subnet\_endpoint\_tgwattacha\_cidr](#input\_subnet\_endpoint\_tgwattacha\_cidr) | CIDR du subnet Endpoint-Tgwattach-A | `string` | n/a | yes |
| <a name="input_subnet_endpoint_tgwattachb_cidr"></a> [subnet\_endpoint\_tgwattachb\_cidr](#input\_subnet\_endpoint\_tgwattachb\_cidr) | CIDR du subnet Endpoint-Tgwattach-B | `string` | n/a | yes |
| <a name="input_subnet_endpointa_cidr"></a> [subnet\_endpointa\_cidr](#input\_subnet\_endpointa\_cidr) | CIDR du subnet Endpoint-A | `string` | n/a | yes |
| <a name="input_subnet_endpointb_cidr"></a> [subnet\_endpointb\_cidr](#input\_subnet\_endpointb\_cidr) | CIDR du subnet Endpoint-B | `string` | n/a | yes |
| <a name="input_subnet_onprem_privatea_cidr"></a> [subnet\_onprem\_privatea\_cidr](#input\_subnet\_onprem\_privatea\_cidr) | CIDR du Subnet OnPrem Private-A | `string` | n/a | yes |
| <a name="input_subnet_onprem_publica_cidr"></a> [subnet\_onprem\_publica\_cidr](#input\_subnet\_onprem\_publica\_cidr) | CIDR du Subnet OnPrem Public-A | `string` | n/a | yes |
| <a name="input_subnet_perimetre_nata_cidr"></a> [subnet\_perimetre\_nata\_cidr](#input\_subnet\_perimetre\_nata\_cidr) | CIDR du subnet Perimetre-Nat-A | `string` | n/a | yes |
| <a name="input_subnet_perimetre_natb_cidr"></a> [subnet\_perimetre\_natb\_cidr](#input\_subnet\_perimetre\_natb\_cidr) | CIDR du subnet Perimetre-Nat-B | `string` | n/a | yes |
| <a name="input_subnet_perimetre_nfwa_cidr"></a> [subnet\_perimetre\_nfwa\_cidr](#input\_subnet\_perimetre\_nfwa\_cidr) | CIDR du subnet Perimetre-Nfw-A | `string` | n/a | yes |
| <a name="input_subnet_perimetre_nfwb_cidr"></a> [subnet\_perimetre\_nfwb\_cidr](#input\_subnet\_perimetre\_nfwb\_cidr) | CIDR du subnet Perimetre-Nfw-B | `string` | n/a | yes |
| <a name="input_subnet_perimetre_tgwattacha_cidr"></a> [subnet\_perimetre\_tgwattacha\_cidr](#input\_subnet\_perimetre\_tgwattacha\_cidr) | CIDR du subnet Perimetre-Tgwattach-A | `string` | n/a | yes |
| <a name="input_subnet_perimetre_tgwattachb_cidr"></a> [subnet\_perimetre\_tgwattachb\_cidr](#input\_subnet\_perimetre\_tgwattachb\_cidr) | CIDR du subnet Perimetre-Tgwattach-B | `string` | n/a | yes |
| <a name="input_subnet_prod_appa_cidr"></a> [subnet\_prod\_appa\_cidr](#input\_subnet\_prod\_appa\_cidr) | CIDR du subnet Prod-App-A | `string` | n/a | yes |
| <a name="input_subnet_prod_appb_cidr"></a> [subnet\_prod\_appb\_cidr](#input\_subnet\_prod\_appb\_cidr) | CIDR du subnet Prod-App-B | `string` | n/a | yes |
| <a name="input_subnet_prod_tgwattacha_cidr"></a> [subnet\_prod\_tgwattacha\_cidr](#input\_subnet\_prod\_tgwattacha\_cidr) | CIDR du subnet Prod-Tgwattach-A | `string` | n/a | yes |
| <a name="input_subnet_prod_tgwattachb_cidr"></a> [subnet\_prod\_tgwattachb\_cidr](#input\_subnet\_prod\_tgwattachb\_cidr) | CIDR du subnet Prod-Tgwattach-B | `string` | n/a | yes |
| <a name="input_tgw_bgp_asn"></a> [tgw\_bgp\_asn](#input\_tgw\_bgp\_asn) | BGP ASN du Transit Gateway AWS | `number` | n/a | yes |
| <a name="input_vpc_dev_cidr"></a> [vpc\_dev\_cidr](#input\_vpc\_dev\_cidr) | CIDR du VPC Dev | `string` | n/a | yes |
| <a name="input_vpc_endpoint_cidr"></a> [vpc\_endpoint\_cidr](#input\_vpc\_endpoint\_cidr) | CIDR du VPC Endpoint | `string` | n/a | yes |
| <a name="input_vpc_endpoint_service_region_cidr"></a> [vpc\_endpoint\_service\_region\_cidr](#input\_vpc\_endpoint\_service\_region\_cidr) | CIDR du VPC dans service\_region. Hors de toute plage routee par la landing zone | `string` | `"192.168.240.0/26"` | no |
| <a name="input_vpc_onprem_cidr"></a> [vpc\_onprem\_cidr](#input\_vpc\_onprem\_cidr) | CIDR du VPC OnPrem | `string` | n/a | yes |
| <a name="input_vpc_perimetre_cidr"></a> [vpc\_perimetre\_cidr](#input\_vpc\_perimetre\_cidr) | CIDR du VPC Perimetre | `string` | n/a | yes |
| <a name="input_vpc_prod_cidr"></a> [vpc\_prod\_cidr](#input\_vpc\_prod\_cidr) | CIDR du VPC Prod | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_central_endpoints"></a> [central\_endpoints](#output\_central\_endpoints) | Liste des info des VPC endpoints deployes |
| <a name="output_nfw_endpoint_1"></a> [nfw\_endpoint\_1](#output\_nfw\_endpoint\_1) | ID du VPC endpoint Nfw dans la zone a |
| <a name="output_nfw_endpoint_2"></a> [nfw\_endpoint\_2](#output\_nfw\_endpoint\_2) | ID du VPC endpoint Nfw dans la zone b |
| <a name="output_nfw_endpoints"></a> [nfw\_endpoints](#output\_nfw\_endpoints) | Liste des NFW endpoints |
| <a name="output_onprem_vpn_eip"></a> [onprem\_vpn\_eip](#output\_onprem\_vpn\_eip) | Info Elastic IP pour le server VPN |
| <a name="output_onprem_vpn_int_id"></a> [onprem\_vpn\_int\_id](#output\_onprem\_vpn\_int\_id) | ID de l'Interface privee du Server VPN |
| <a name="output_ram_tgw_share_arns"></a> [ram\_tgw\_share\_arns](#output\_ram\_tgw\_share\_arns) | Liste des Arn des ressources share RAM pour Tgw |
| <a name="output_subnet_onprem_privatea_id"></a> [subnet\_onprem\_privatea\_id](#output\_subnet\_onprem\_privatea\_id) | ID du Subnet OnPrem Private-A |
| <a name="output_subnet_onprem_publica_id"></a> [subnet\_onprem\_publica\_id](#output\_subnet\_onprem\_publica\_id) | ID du Subnet OnPrem Public-A |
| <a name="output_tgw_id"></a> [tgw\_id](#output\_tgw\_id) | ID du Transit Gateway Principal |
| <a name="output_tgw_rt_core_id"></a> [tgw\_rt\_core\_id](#output\_tgw\_rt\_core\_id) | ID de la table de routage Core du Tgw |
| <a name="output_tgw_rt_onprem_id"></a> [tgw\_rt\_onprem\_id](#output\_tgw\_rt\_onprem\_id) | ID de la table de routage Onprem du Tgw |
| <a name="output_tgw_rt_segregated_id"></a> [tgw\_rt\_segregated\_id](#output\_tgw\_rt\_segregated\_id) | ID de la table de routage Segragated du Tgw |
| <a name="output_tgw_rt_shared_id"></a> [tgw\_rt\_shared\_id](#output\_tgw\_rt\_shared\_id) | ID de la table de routage Shared du Tgw |
| <a name="output_tgwattach_dev_id"></a> [tgwattach\_dev\_id](#output\_tgwattach\_dev\_id) | ID de l'attachement Tgw du VPC Dev |
| <a name="output_tgwattach_endpoint_id"></a> [tgwattach\_endpoint\_id](#output\_tgwattach\_endpoint\_id) | ID de l'attachement Tgw du VPC Endpoint |
| <a name="output_tgwattach_perimetre_id"></a> [tgwattach\_perimetre\_id](#output\_tgwattach\_perimetre\_id) | ID de l'attachement Tgw du VPC Perimetre |
| <a name="output_tgwattach_prod_id"></a> [tgwattach\_prod\_id](#output\_tgwattach\_prod\_id) | ID de l'attachement Tgw du VPC Prod |
| <a name="output_vpc_dev_id"></a> [vpc\_dev\_id](#output\_vpc\_dev\_id) | ID du VPC Dev |
| <a name="output_vpc_endpoint_id"></a> [vpc\_endpoint\_id](#output\_vpc\_endpoint\_id) | ID du VPC Endpoint |
| <a name="output_vpc_onprem_cidr"></a> [vpc\_onprem\_cidr](#output\_vpc\_onprem\_cidr) | CIDR du VPC Onprem |
| <a name="output_vpc_onprem_id"></a> [vpc\_onprem\_id](#output\_vpc\_onprem\_id) | ID du VPC Onprem |
| <a name="output_vpc_perimetre_id"></a> [vpc\_perimetre\_id](#output\_vpc\_perimetre\_id) | ID du VPC Perimetre |
| <a name="output_vpc_prod_id"></a> [vpc\_prod\_id](#output\_vpc\_prod\_id) | ID du VPC Prod |
| <a name="output_vpn_connection_attributes"></a> [vpn\_connection\_attributes](#output\_vpn\_connection\_attributes) | Configurations du VPN Cloud |
| <a name="output_vpn_server_instance_id"></a> [vpn\_server\_instance\_id](#output\_vpn\_server\_instance\_id) | ID de l'instance du serveur VPN On Prem |
<!-- END_TF_DOCS -->