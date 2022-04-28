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

  source = "../module/ec2"

  public_ec2_count     = "3"
  private_ec2_count     = "3"
  name          = local.name
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  azs            = module.vpc.azs
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  pub_security_group_id = module.pub-security-group.the_security_group_id
  priv_security_group_id = module.priv-security-group.the_security_group_id

  tags = local.tags
}


#################################
# Security group
#################################
module "pub-security-group" {
  source = "../module/securitygroup"

  name        = "public-sg"
  description = "Public security group"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = false
  ingress_cidr_blocks = ["68.144.113.14/32"]
  ingress_rules       = ["ssh-tcp","https-443-tcp"]

  tags = local.tags

}

module "priv-security-group" {
  source = "../module/securitygroup"

  name        = "web2app-sg"
  description = "Web to App security group"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = false
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  ingress_rules       = ["http-80-tcp","http-8080-tcp"]

  tags = local.tags

}



