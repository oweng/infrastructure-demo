## Creating VPC

resource "aws_eip" "nat" {
  count = var.nat_node_count
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.8.1"
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = var.vpc_azs
  private_subnets      = var.vpc_private_subnets
  public_subnets       = var.vpc_public_subnets
  enable_nat_gateway   = var.vpc_enable_nat_gateway
  enable_vpn_gateway   = var.vpc_enable_vpn_gateway
  enable_dns_hostnames = var.vpc_dnsnames
  enable_dns_support   = var.vpc_dnssupport
  reuse_nat_ips        = var.vpc_reuse_nat_ips
  external_nat_ip_ids  = aws_eip.nat.*.id

  tags = {
    Environment = var.tag_environment
  }
}
