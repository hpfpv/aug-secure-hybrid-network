module "tgw_principal" {
    providers = {
      aws = aws.network
    }
    source                              = "./modules/tgw"
    ram_principals                      = var.ram_principals
    tgw_bgp_asn                         = var.tgw_bgp_asn
    resource_prefix                     = var.resource_prefix
}

module "vpc_perimetre" {
    depends_on = [ 
        module.tgw_principal
    ]
    providers = {
      aws = aws.perimetre
    }
    source                              = "./modules/vpc-perimetre"
    vpc_cidr                            = var.vpc_perimetre_cidr
    subnet_tgwattacha_cidr              = var.subnet_perimetre_tgwattacha_cidr
    subnet_tgwattachb_cidr              = var.subnet_perimetre_tgwattachb_cidr
    subnet_nfwa_cidr                    = var.subnet_perimetre_nfwa_cidr
    subnet_nfwb_cidr                    = var.subnet_perimetre_nfwb_cidr
    subnet_nata_cidr                    = var.subnet_perimetre_nata_cidr
    subnet_natb_cidr                    = var.subnet_perimetre_natb_cidr
    tgw_principal_id                    = module.tgw_principal.tgw_id
    ram_tgw_resource_share_arns         = module.tgw_principal.ram_tgw_share_arns
    use_central_endpoints               = false
    # central_endpoints_phz               = module.vpc_endpoint.central_endpoints_phz
    resource_prefix                     = var.resource_prefix
}

module "tgw_route_0" {
    depends_on = [ 
        module.tgw_principal,
        module.vpc_perimetre
    ]
    providers = {
      aws = aws.network
    }
    vpc_perimetre_tgwattach_id          = module.vpc_perimetre.tgwattach_id
    source                              = "./modules/tgw-route-0"
    tgw_association_route_table_ids     = [module.tgw_principal.tgw_rt_core_id] # Pour le VPC Perimetre
    tgw_propagation_route_table_ids     = []                                    # Pour le VPC Perimetre
    tgw_rt_shared_id                    = module.tgw_principal.tgw_rt_shared_id
    tgw_rt_segregated_id                = module.tgw_principal.tgw_rt_segregated_id
    resource_prefix                     = var.resource_prefix
}

module "vpc_endpoint" {
    providers = {
      aws = aws.network
    }
    source                              = "./modules/vpc-endpoint"
    vpc_cidr                            = var.vpc_endpoint_cidr
    subnet_tgwattacha_cidr              = var.subnet_endpoint_tgwattacha_cidr
    subnet_tgwattachb_cidr              = var.subnet_endpoint_tgwattachb_cidr
    subnet_endpointa_cidr               = var.subnet_endpointa_cidr 
    subnet_endpointb_cidr               = var.subnet_endpointb_cidr 
    tgw_principal_id                    = module.tgw_principal.tgw_id
    tgw_association_route_table_ids     = [module.tgw_principal.tgw_rt_core_id]
    tgw_propagation_route_table_ids     = [module.tgw_principal.tgw_rt_core_id, module.tgw_principal.tgw_rt_shared_id, module.tgw_principal.tgw_rt_segregated_id, module.tgw_principal.tgw_rt_onprem_id]
    services                            = ["ec2", "ssm", "ec2messages", "ssmmessages", "kms", "logs", "cloudformation", "secretsmanager", "monitoring"]
    resource_prefix                     = var.resource_prefix
    region                              = var.region
}

module "vpc_dev" {
    providers = {
      aws = aws.network
    }
    source                              = "./modules/vpc-dev"
    vpc_cidr                            = var.vpc_dev_cidr
    subnet_tgwattacha_cidr              = var.subnet_dev_tgwattacha_cidr
    subnet_tgwattachb_cidr              = var.subnet_dev_tgwattachb_cidr
    subnet_appa_cidr                    = var.subnet_dev_appa_cidr
    subnet_appb_cidr                    = var.subnet_dev_appb_cidr
    tgw_principal_id                    = module.tgw_principal.tgw_id
    tgw_association_route_table_ids     = [module.tgw_principal.tgw_rt_segregated_id]
    tgw_propagation_route_table_ids     = [module.tgw_principal.tgw_rt_core_id, module.tgw_principal.tgw_rt_shared_id, module.tgw_principal.tgw_rt_onprem_id]
    use_central_endpoints               = true
    central_endpoints_phz               = module.vpc_endpoint.central_endpoints_phz
    subnet_sharing_principals           = []
    resource_prefix                     = var.resource_prefix
}

module "vpc_prod" {
    providers = {
      aws = aws.network
    }
    source                              = "./modules/vpc-prod"
    vpc_cidr                            = var.vpc_prod_cidr
    subnet_tgwattacha_cidr              = var.subnet_prod_tgwattacha_cidr
    subnet_tgwattachb_cidr              = var.subnet_prod_tgwattachb_cidr
    subnet_appa_cidr                    = var.subnet_prod_appa_cidr
    subnet_appb_cidr                    = var.subnet_prod_appb_cidr
    tgw_principal_id                    = module.tgw_principal.tgw_id
    tgw_association_route_table_ids     = [module.tgw_principal.tgw_rt_segregated_id]
    tgw_propagation_route_table_ids     = [module.tgw_principal.tgw_rt_core_id, module.tgw_principal.tgw_rt_shared_id, module.tgw_principal.tgw_rt_onprem_id]
    use_central_endpoints               = true
    central_endpoints_phz               = module.vpc_endpoint.central_endpoints_phz
    subnet_sharing_principals           = []
    resource_prefix                     = var.resource_prefix
}

module "vpc_onprem" {
    providers = {
      aws = aws.network_onprem
    }
    source                              = "./modules/vpc-onprem"
    cloud_cidr                          = var.cloud_cidr
    vpc_cidr                            = var.vpc_onprem_cidr
    subnet_privatea_cidr                = var.subnet_onprem_privatea_cidr
    subnet_publica_cidr                 = var.subnet_onprem_publica_cidr
    cloud_vpn_config                    = module.vpn_cloud.vpn_connection_attributes
    server_vpn_private_ips              = var.server_vpn_private_ips
    resource_prefix                     = var.resource_prefix
}

module "vpn_cloud" {
    providers = {
      aws = aws.network
    }
    source                              = "./modules/vpn-cloud"
    cgw_bgp_asn                         = var.cgw_bgp_asn
    cgw_ip                              = module.vpc_onprem.onprem_vpn_eip.public_ip
    tgw_principal_id                    = module.tgw_principal.tgw_id
    tgw_association_route_table_ids     = [module.tgw_principal.tgw_rt_onprem_id]
    tgw_propagation_route_table_ids     = [module.tgw_principal.tgw_rt_core_id, module.tgw_principal.tgw_rt_shared_id, module.tgw_principal.tgw_rt_segregated_id]
    resource_prefix                     = var.resource_prefix
}

module "vpn_onprem" {
    depends_on = [ 
        module.vpc_onprem,
        module.vpn_cloud
    ]
    providers = {
      aws = aws.network_onprem
    }
    source                              = "./modules/vpn-onprem"
    cgw_bgp_asn                         = var.cgw_bgp_asn
    tgw_bgp_asn                         = var.tgw_bgp_asn
    cloud_cidr                          = var.cloud_cidr
    onprem_cidr                         = module.vpc_onprem.vpc_cidr
    onprem_subnet_publica_id            = module.vpc_onprem.subnet_publica_id
    server_vpn_instance_type            = var.server_vpn_instance_type
    onprem_vpn_eip                      = module.vpc_onprem.onprem_vpn_eip
    onprem_vpn_int_id                   = module.vpc_onprem.onprem_vpn_int_id
    cloud_vpn_config                    = module.vpn_cloud.vpn_connection_attributes
    resource_prefix                     = var.resource_prefix
}