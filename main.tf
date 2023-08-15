module "tgw_principal" {
    providers = {
      aws = aws.network
    }
    source                              = "./modules/tgw"
    ram_principals                      = var.ram_principals
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
    resource_prefix                     = var.resource_prefix
}

module "vpn_onprem" {
    providers = {
      aws = aws.network
    }
    source                              = "./modules/vpn"
    cgw_bgp_asn                         = var.cgw_bgp_asn
    cgw_ip                              = var.cgw_ip
    tgw_principal_id                    = module.tgw_principal.tgw_id
    tgw_association_route_table_ids     = [module.tgw_principal.tgw_rt_onprem_id]
    tgw_propagation_route_table_ids     = [module.tgw_principal.tgw_rt_core_id, module.tgw_principal.tgw_rt_shared_id, module.tgw_principal.tgw_rt_segregated_id]
    resource_prefix                     = var.resource_prefix
}
