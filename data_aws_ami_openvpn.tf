data "aws_ami" "openvpn" {
  most_recent = true

  filter {
    name = "name"

    values = [var.aws_ami_filter]
  }

  owners = [var.ami_owner_account]
}