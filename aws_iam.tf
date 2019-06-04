# IAM Policies

data "aws_iam_policy_document" "openvpn_assume_role" {
  statement {
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "openvpn_eip" {
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:AssociateAddress",
      "ec2:AllocateAddress",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "openvpn_role" {
  name               = "openvpn-iam-role"
  assume_role_policy = "${data.aws_iam_policy_document.openvpn_assume_role.json}"
}

resource "aws_iam_policy" "openvpn_policy" {
  name        = "openvpn-iam-policy"
  description = "Allows the openvpn server to attach an EIP"
  policy      = "${data.aws_iam_policy_document.openvpn_eip.json}"
}

resource "aws_iam_instance_profile" "openvpn_profile" {
  name = "openvpn-instance-profile"
  role = "${aws_iam_role.openvpn_role.name}"
}

resource "aws_iam_role_policy_attachment" "openvpn_attach" {
  role       = "${aws_iam_role.openvpn_role.name}"
  policy_arn = "${aws_iam_policy.openvpn_policy.arn}"
}