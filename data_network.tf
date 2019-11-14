data "aws_vpc" "openvpn" {
  cidr_block = var.vpc_cidr_range
}

data "aws_availability_zones" "available" {
}

data "aws_region" "current" {}
