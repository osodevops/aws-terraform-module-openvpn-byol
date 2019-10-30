data "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_range
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Zone = "Private"
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Zone = "Public"
  }
}

data "aws_availability_zones" "available" {
}

