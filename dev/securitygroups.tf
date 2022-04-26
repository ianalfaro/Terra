
module "security_group" {
  source = "../module/vpc"

  name = local.name

  description = "Security group with fixed name"
  vpc_id      = module.vpc.vpc_id

  use_name_prefix = false

  ingress_cidr_blocks = ["10.10.0.0/16"]
  ingress_rules       = [443, 443, "tcp", "HTTPS"]
}
