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
  name   = "client-int"
  region = "us-east-1"
  tags = {
    Owner       = "corp"
    Environment = "int"
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

  region = "us-east-1"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.52.30.0/28", "10.52.30.16/28"]
  public_subnets  = ["10.52.20.0/28", "10.51.20.16/28"]
  subnet_count    = "2"

  tags = {
    Terraform   = "true"
    Environment = "int"
  }
}

################################################################################
# EC2 Module
################################################################################
module "ec2_multiple" {
  # depends_on=[module.vpc]

  source = "../module/ec2"

  ec2_count     = "1"
  name          = local.name
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  azs            = module.vpc.azs
  public_subnets = module.vpc.public_subnets

  tags = local.tags
}