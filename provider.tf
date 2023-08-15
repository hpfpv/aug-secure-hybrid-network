terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 4.47"
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
  region =  var.region
  alias = "perimetre"
  assume_role {
    role_arn = var.assume_role_perimetre
    session_name = "terraform_perimetre"
  }
}