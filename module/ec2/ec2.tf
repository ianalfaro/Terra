# module "vpc" {
#   source = "../vpc"
# }

resource "aws_instance" "mod" {
  count = var.ec2_count

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "${var.name}-ssh_key"

  availability_zone = var.azs[count.index]
  subnet_id         = var.public_subnets[count.index]


  tags = merge(
    {
      "Name" = "${var.name}-${var.public_subnet_suffix}-${count.index + 1}"
    },
    var.tags,
  )
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "ec2_ssh_key" {
  key_name   = "${var.name}-ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}