
resource "aws_instance" "public_ec2" {
  count = var.public_ec2_count

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "${var.name}-ssh_key"

  availability_zone = var.azs[count.index]
  subnet_id         = var.public_subnets[count.index]
  associate_public_ip_address = "true"
  vpc_security_group_ids =  var.pub_security_group_id

  tags = merge(
    {
      "Name" = "${var.name}-${var.public_subnet_suffix}-${count.index + 1}"
    },
    var.tags,
  )
}

resource "aws_instance" "private_ec2" {
  count = var.private_ec2_count

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "${var.name}-ssh_key"

  availability_zone = var.azs[count.index]
  subnet_id         = var.private_subnets[count.index]
  vpc_security_group_ids =  var.priv_security_group_id

  tags = merge(
    {
      "Name" = "${var.name}-${var.private_subnet_suffix}-${count.index + 1}"
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

resource "local_file" "ssh_key" {
  filename = "${var.name}-ssh_key.pem"
  content = tls_private_key.ssh_key.private_key_pem
}