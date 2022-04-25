terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = local.region
}

locals {
  name   = "client-dev"
  region = "us-east-1"
  tags = {
    Owner       = "corp"
    Environment = "dev"
    Terraform   = "true"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}


################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../module/vpc"

  name = local.name
  cidr = "10.51.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.51.30.0/28", "10.51.30.16/28", "10.51.30.32/28"]
  public_subnets  = ["10.51.20.0/28", "10.51.20.16/28", "10.51.20.32/28"]
  subnet_count    = "3"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags

}

################################################################################
# EC2 Module
################################################################################
module "ec2_multiple" {
  # depends_on=[module.vpc]

  source = "../module/ec2"

  ec2_count     = "3"
  name          = local.name
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  azs            = module.vpc.azs
  public_subnets = module.vpc.public_subnets

  tags = local.tags
}
