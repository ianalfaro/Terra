
##################################
# Get ID of created Security Group
##################################
locals {
  create = var.create

  this_sg_id = var.create_sg ? concat(aws_security_group.mod.*.id, aws_security_group.use_name_prefix.*.id, [""])[0] : var.security_group_id
}

##########################
# Security group
##########################
resource "aws_security_group" "mod" {
  count = local.create && var.create_sg && !var.use_name_prefix ? 1 : 0

  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )

  timeouts {
    create = var.create_timeout
    delete = var.delete_timeout
  }
}

#################################
# Security group with name_prefix
#################################
resource "aws_security_group" "use_name_prefix" {
  count = local.create && var.create_sg && var.use_name_prefix ? 1 : 0

  name_prefix            = "${var.name}-"
  description            = var.description
  vpc_id                 = var.vpc_id


  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    create = var.create_timeout
    delete = var.delete_timeout
  }
}

###################################
# Ingress - List of rules (simple)
###################################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "aws_security_group_rule" "ingress_rules" {
  count = local.create ? length(var.ingress_rules) : 0

  security_group_id = local.this_sg_id
  type              = "ingress"

  cidr_blocks      = var.ingress_cidr_blocks
  ipv6_cidr_blocks = var.ingress_ipv6_cidr_blocks
  prefix_list_ids  = var.ingress_prefix_list_ids
  description      = var.rules[var.ingress_rules[count.index]][3]

  from_port = var.rules[var.ingress_rules[count.index]][0]
  to_port   = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
}

variable "description" {
  description = "Description of security group"
  type        = string
  default     = "Security Group managed by Terraform"
}


#resource "aws_security_group" "public_security_group" {
#  name        = "public_security_group"
#  description = "rules for public facing servers"
#  vpc_id      = local.vpc_id
#
#  ingress {
#    description      = "TLS into pub servers"
#    from_port        = 443
#    to_port          = 443
#    protocol         = "tcp"
#    cidr_blocks      = ["68.144.113.14/32"]
#  }
#
#  ingress {
#    description      = "SSH into pub servers"
#    from_port        = 22
#    to_port          = 22
#    protocol         = "tcp"
#    cidr_blocks      = ["68.144.113.14/32"]
#  }
#
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#  }
#
#  tags = merge(
#    { "Name" = "${var.name}-${var.public_subnet_suffix}" },
#    var.tags,
#  )
#}