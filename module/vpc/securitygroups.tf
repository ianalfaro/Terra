
################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "public_security_group" {
  name        = "public_security_group"
  description = "rules for public facing servers"
  vpc_id      = local.vpc_id

  ingress {
    description      = "TLS into pub servers"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["68.144.113.14/32"]
  }

  ingress {
    description      = "SSH into pub servers"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["68.144.113.14/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    { "Name" = "${var.name}-${var.public_subnet_suffix}" },
    var.tags,
  )
}