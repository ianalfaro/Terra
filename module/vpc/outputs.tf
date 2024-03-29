output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.mod.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.mod.cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "db_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.db[*].id
}

output "db_subnets_cidr_blocks" {
  description = "List of cidr_blocks of DB subnets"
  value       = aws_subnet.db[*].cidr_block
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs[*]
}
