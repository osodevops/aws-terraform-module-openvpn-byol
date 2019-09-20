resource "null_resource" "s3_bucket_upload" {
  triggers = {
    test = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "aws --profile ${var.aws_cli_profile} --no-verify-ssl s3 sync ansible s3://${aws_s3_bucket.ssm_ansible_bucket.id}"
  }
}