data "aws_ami" "openvpn" {
  most_recent = true

  filter {
    name = "name"

    values = ["ENC-OPENVPN-*"]
  }

  owners = ["${var.ami_owner_account}"]
}
