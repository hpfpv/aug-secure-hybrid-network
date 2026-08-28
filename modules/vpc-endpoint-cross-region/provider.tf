terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 6.x requis : `supported_regions` sur aws_vpc_endpoint_service et
      # `service_region` sur aws_vpc_endpoint n'existent pas avant.
      version = ">= 6.0"
    }
  }
}
