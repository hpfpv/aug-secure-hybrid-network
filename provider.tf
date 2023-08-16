terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 5.12.0"
    }
  }
}

provider "aws" {
  region =  var.region
  alias = "network"
  assume_role {
    role_arn = var.assume_role_network
    session_name = "terraform_network"
  }
}

provider "aws" {
  region =  var.onprem_region
  alias = "network_onprem"
  assume_role {
    role_arn = var.assume_role_network
    session_name = "terraform_network_onprem"
  }
}

provider "aws" {
  region =  var.region
  alias = "perimetre"
  assume_role {
    role_arn = var.assume_role_perimetre
    session_name = "terraform_perimetre"
  }
}