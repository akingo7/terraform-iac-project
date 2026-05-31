terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.40.0"
    }
  }
}

provider "aws" {
  region = var.region
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

resource "aws_key_pair" "infrakey" {
  key_name   = var.keypair
  public_key = file("${path.module}/keys/infrakey.pub")
}

module "network" {
  source                              = "./modules/network"
  cidr_block                          = var.cidr_block
  enable_dns_support                  = var.cidr_block
  enable_dns_hostnames                = var.cidr_block
  preferred_number_of_public_subnets  = var.cidr_block
  preferred_number_of_private_subnets = var.cidr_block
  tags                                = var.cidr_block
}