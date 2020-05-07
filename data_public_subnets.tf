data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.openvpn.id

  tags = {
    Type = "Public*"
  }
}