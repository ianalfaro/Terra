terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6.0"
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
  db_subnets = ["10.51.40.0/28", "10.51.40.16/28"]
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

module "db-security-group" {
  source = "../module/securitygroup"

  name        = "db-sg"
  description = "DB security group"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = false
  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  ingress_rules       = ["mssql-tcp"]

  tags = local.tags

}

#################################
# RDS
#################################

module "db" {
  source  = "../module/rds"

  identifier = "demodb-mssql"

  engine            = "sqlserver-ex"
  engine_version    = "14.00.3401.7.v1"
  major_engine_version = "14.00"
  instance_class    = "db.t2.micro"

  storage_type = "gp2"
  allocated_storage = 20
  storage_encrypted = false

  username = "demodbuser"
  password = "demodbpw"
  port     = "1433"

#  iam_database_authentication_enabled = true
  create_db_subnet_group = true
  subnet_ids             = module.vpc.db_subnets
  vpc_security_group_ids = module.db-security-group.the_security_group_id
  multi_az               = false

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0
  deletion_protection = false
  skip_final_snapshot     = true

  enabled_cloudwatch_logs_exports = ["error"]
  create_cloudwatch_log_group     = true

#  performance_insights_enabled          = true
#  performance_insights_retention_period = 7
#  create_monitoring_role                = true
#  monitoring_interval                   = 60

  options                   = []
  create_db_parameter_group = false
#  license_model             = "license-included"
  timezone                  = "GMT Standard Time"
  character_set_name        = "Latin1_General_CI_AS"


  tags = {
    Owner       = "corp"
    Environment = "dev"
  }



#  # DB option group
#  major_engine_version = "5.7"

  # Database Deletion Protection


#  parameters = [
#    {
#      name = "character_set_client"
#      value = "utf8mb4"
#    },
#    {
#      name = "character_set_server"
#      value = "utf8mb4"
#    }
#  ]

#  options = [
#    {
#      option_name = "MARIADB_AUDIT_PLUGIN"
#
#      option_settings = [
#        {
#          name  = "SERVER_AUDIT_EVENTS"
#          value = "CONNECT"
#        },
#        {
#          name  = "SERVER_AUDIT_FILE_ROTATIONS"
#          value = "37"
#        },
#      ]
#    },
#  ]
}
