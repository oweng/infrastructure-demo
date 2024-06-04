variable "region" {
  default = "us-east-1"
  type    = string
}

variable "tag_environment" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "nat_node_count" {
  type = string
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "vpc_enable_nat_gateway" {
  type = bool
}

variable "vpc_enable_vpn_gateway" {
  type = bool
}

variable "vpc_reuse_nat_ips" {
  type = bool
}

variable "vpc_dnsnames" {
  type = bool
}

variable "vpc_dnssupport" {
  type = string
}

variable "environment" {
  type    = string
  default = "demo"
}
