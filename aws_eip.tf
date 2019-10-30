resource "aws_eip" "openvpn" {
  count = 1
  tags  = var.common_tags
}

