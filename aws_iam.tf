# IAM Policies

data "aws_iam_policy_document" "openvpn_assume_role" {
  statement {
    principals {
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com"
        ]
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
      "kms:CreateGrant"
    ]

    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:HeadBucket",
      "s3:ListObjects",
      "s3:GetObject"
    ]

    resources = ["arn:aws:s3:::${aws_s3_bucket.ssm_ansible_bucket.name}"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = ["arn:aws:route53:::hostedzone/${var.r53_hosted_zone_id}"]
    effect = "Allow"
  }
}

resource "aws_iam_role" "openvpn_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.openvpn_assume_role.json
}

resource "aws_iam_policy" "openvpn_policy" {
  name        = var.iam_policy_name
  description = "Allows the openvpn server to attach an EIP"
  policy      = data.aws_iam_policy_document.openvpn_eip.json
}

resource "aws_iam_instance_profile" "openvpn_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.openvpn_role.name
}

resource "aws_iam_role_policy_attachment" "openvpn_attach" {
  role       = aws_iam_role.openvpn_role.name
  policy_arn = aws_iam_policy.openvpn_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach_ssm" {
  role       = aws_iam_role.openvpn_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_attach_ec2_role" {
  role       = aws_iam_role.openvpn_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm_attach_clw_agent" {
  role       = aws_iam_role.openvpn_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_attach_clw_logs" {
  role       = aws_iam_role.openvpn_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

