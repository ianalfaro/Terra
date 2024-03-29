
variable "public_ec2_count" {
  description = "Number of public ec2 instances"
  type        = string
  default     = ""
}

variable "private_ec2_count" {
  description = "Number of private ec2 instances"
  type        = string
  default     = ""
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = ""
}


variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "pub_security_group_id" {
  description = "Security Groups"
  type        = list(string)
  default     = []
}

variable "priv_security_group_id" {
  description = "Security Groups"
  type        = list(string)
  default     = []
}