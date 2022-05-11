locals {
  vpc_id = aws_vpc.mod.id
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "mod" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

   tags = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count             = var.subnet_count
  vpc_id            = local.vpc_id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = format(
        "${var.name}-${var.public_subnet_suffix}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = var.subnet_count

  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = format(
        "${var.name}-${var.private_subnet_suffix}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

################################################################################
# DB subnet
################################################################################

resource "aws_subnet" "db" {
  count = var.db_subnet_count

  vpc_id            = local.vpc_id
  cidr_block        = var.db_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = format(
        "${var.name}--${var.db_subnet_suffix}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}


################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "mod" {

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}


