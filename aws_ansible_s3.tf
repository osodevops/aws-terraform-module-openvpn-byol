resource "aws_s3_bucket_object" "db_ansible_playbook" {
  bucket  = aws_s3_bucket.ssm_ansible_bucket.id
  key     = "ansible/openvpn_db_ansible_playbook.yaml"
  content = data.template_file.db_ansible_playbook.rendered
}

resource "aws_s3_bucket_object" "ssl_ansible_playbook" {
  bucket  = aws_s3_bucket.ssm_ansible_bucket.id
  key     = "ansible/openvpn_ssl_ansible_playbook.yaml"
  content = data.template_file.ssl_ansible_playbook.rendered
}

resource "aws_s3_bucket_object" "update_ansible_playbook" {
  bucket  = aws_s3_bucket.ssm_ansible_bucket.id
  key     = "ansible/openvpn_update_ansible_playbook.yaml"
  content = data.template_file.update_ansible_playbook.rendered
}