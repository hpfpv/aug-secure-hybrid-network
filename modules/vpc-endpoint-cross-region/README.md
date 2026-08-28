# vpc-endpoint-cross-region

Makes an AWS service that only exists in another Region reachable privately,
from a landing zone that cannot create resources outside its home Region.

Cross-Region PrivateLink covers two different things. Customer endpoint
services, the ones you build yourself behind a Network Load Balancer, and a
short list of AWS services. A service on neither list has no private path.

This module builds one. It puts an interface endpoint for the service in a
small VPC in the service Region, fronts it with an NLB whose targets are that
endpoint's own ENI addresses, and publishes the NLB as a customer endpoint
service enabled for the consumer Region.

The NLB is not load balancing. An endpoint service is the only construct AWS
lets you share across Regions and an endpoint service requires an NLB, so it is
an adapter: it turns a service endpoint that cannot leave its Region into a
customer service that can.

The consumer half lives in `modules/vpc-endpoint`, so the endpoint and its
private hosted zone are created beside the in-region ones and distributed
through the same `central_endpoints_phz` output. Spoke VPCs need no change.

## Usage

```hcl
module "vpc_endpoint_cross_region" {
  providers = { aws = aws.network_service_region }
  source    = "./modules/vpc-endpoint-cross-region"

  service_region     = "us-east-1"
  consumer_region    = "ca-central-1"
  vpc_cidr           = "192.168.240.0/26"
  availability_zones = ["us-east-1b", "us-east-1c"]
  resource_prefix    = var.resource_prefix

  services = [{
    name     = "bedrock-mantle"
    dns_name = "bedrock-mantle.us-east-1.api.aws"
  }]
}

module "vpc_endpoint" {
  # ...
  cross_region_endpoints = module.vpc_endpoint_cross_region.endpoint_services
}
```

Read `dns_name` from the service. Never derive it:

```bash
aws ec2 describe-vpc-endpoint-services --region us-east-1 \
  --filters Name=service-name,Values=com.amazonaws.us-east-1.bedrock-mantle \
  --query 'ServiceDetails[].{AZs:AvailabilityZones,Private:PrivateDnsName}'
```

## Permissions

The role that applies this needs the `vpce:AllowMultiRegion` permission-only
action, on both sides: to publish the endpoint service to a second Region, and
to create the consumer endpoint. No SCP may deny it. Scope it with
`ec2:VpceSupportedRegion` for the provider and `ec2:VpceServiceRegion` for the
consumer.

In a landing zone that locks resource creation to the home Region, only the
automation roles can build this. There is no console fallback.

## Things that will catch you out

The module fails the plan on the first three rather than letting them through.

1. **TCP health checks, never HTTP.** An AWS service endpoint serves no health
   path, so an HTTP check reports every healthy target as unhealthy. This is
   almost certainly why the few community reports of this pattern say it does
   not work.
2. **The service is not in every AZ.** `bedrock-mantle` is offered in three of
   the six AZs in `us-east-1`. A precondition compares the requested AZs against
   what the service actually reports.
3. **Cross-Region PrivateLink is unsupported in some zone IDs**: `use1-az3`,
   `usw1-az2`, `apne1-az3`, `apne2-az2`, `apne2-az4`. Zone *names* map to
   different physical zones per account, so the check runs in the deploying
   account.
4. **The DNS record sits at the zone apex**, where a CNAME is not allowed. The
   consumer side uses an A-record alias, pointed at the endpoint's regional DNS
   entry and never a zonal one.
5. **Do not set a custom TCP idle timeout on the NLB.** Cross-Region access is
   not supported for a load balancer that has one.

Endpoint ENI addresses are designated through `subnet_configuration` rather than
discovered. That keeps the NLB targets known at plan time, so the module applies
in a single pass, and keeps them stable if AWS replaces an ENI.

## Status

The pattern is undocumented, not blessed. AWS says nothing about registering an
AWS-managed endpoint's ENIs as load balancer targets, neither that you may nor
that you may not.

It was measured. Targets go healthy, the service presents its own certificate
for its real hostname through the load balancer, and a request from a VPC with
no internet gateway and no NAT gateway reaches the service and gets an
application-level response. What has not been tested is a SigV4-signed call, or
the hop over a transit gateway rather than inside one VPC.

Expect to delete this. When the service joins the cross-Region AWS services
list, the consumer endpoint points straight at it and this module goes away.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [aws_vpc_endpoint_service_allowed_principal.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service_allowed_principal) | resource |
| [aws_availability_zones.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_vpc_endpoint_service.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Exactement deux AZ dans la region du service, par nom.<br><br>Deux contraintes se croisent. Le service n'est pas offert dans toutes<br>les AZ, et PrivateLink cross-region ne fonctionne pas dans quelques ID<br>de zone. Les noms de zone pointent vers des ID differents selon le<br>compte : la precondition sur le NLB verifie les ID dans CE compte. | `list(string)` | n/a | yes |
| <a name="input_consumer_region"></a> [consumer\_region](#input\_consumer\_region) | Region principale, celle qui consommera l'endpoint service | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefixe pour le nom des ressources | `string` | n/a | yes |
| <a name="input_service_region"></a> [service\_region](#input\_service\_region) | Region ou vit le service AWS, celle que la region principale ne peut pas joindre en prive | `string` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | Services a republier. Le nom DNS est explicite et jamais deduit : tous<br>les services ne repondent pas sur <service>.<region>.amazonaws.com,<br>plusieurs services recents utilisent .api.aws. Le deduire produit une<br>zone valide qui ne resout rien.<br><br>  aws ec2 describe-vpc-endpoint-services --region <service\_region> \<br>    --filters Name=service-name,Values=com.amazonaws.<service\_region>.<name> \<br>    --query 'ServiceDetails[].PrivateDnsName' | <pre>list(object({<br>        name     = string<br>        dns_name = string<br>    }))</pre> | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR du VPC dans la region du service. Il ne contient que des ENI<br>d'endpoint et des noeuds NLB : un /26 suffit.<br><br>A choisir hors de toute plage routee ou blackholee par la landing zone.<br>Ce VPC n'est jamais appaire ni attache a un Tgw : une plage<br>volontairement etrangere rend evident dans les logs qu'il ne fait pas<br>partie du reseau route. | `string` | `"192.168.240.0/26"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_services"></a> [endpoint\_services](#output\_endpoint\_services) | Contrat consomme par le module vpc-endpoint : nom du service, nom DNS reel et region |
| <a name="output_service_endpoint_ips"></a> [service\_endpoint\_ips](#output\_service\_endpoint\_ips) | Adresses designees des ENI d'endpoint, telles qu'enregistrees dans le NLB |
<!-- END_TF_DOCS -->