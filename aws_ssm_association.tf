resource "aws_ssm_association" "openvpn-db-migration-playbook" {
  name                = "AWS-RunAnsiblePlaybook"
  association_name    = "openvpn-db-migration-playbook"
  schedule_expression = "rate(1 day)"

  output_location {
    s3_bucket_name = "${aws_s3_bucket.bucket.id}"
  }

  parameters {
    playbook    = ""
    playbookurl = ""
    extravars   = "SSM=True"
    check       = "False"
  }

  targets {
    key    = ""
    values = [""]
  }
}