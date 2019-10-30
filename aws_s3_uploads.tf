resource "null_resource" "s3_bucket_upload" {
  triggers = {
    test = uuid()
  }

  provisioner "local-exec" {
    command = "aws --no-verify-ssl s3 sync ansible s3://${aws_s3_bucket.ssm_ansible_bucket.id}"
  }
}

