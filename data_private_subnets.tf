data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.openvpn.id

  tags = {
    Type = "Private*"
  }
}