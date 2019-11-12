resource "aws_s3_bucket_object" "db_migration_ansible_playbook" {
  bucket  = "${aws_s3_bucket_object.db_migration_ansible_playbook.id}"
  key     = "ansible/openvpn_db_migration_ansible_playbook.yaml"
  content = "${data.template_file.db_migration_ansible_playbook.rendered}"
}

resource "aws_s3_bucket_object" "db_restore_ansible_playbook" {
  bucket  = "${aws_s3_bucket_object.db_restore_ansible_playbook.id}"
  key     = "ansible/openvpn_db_restore_ansible_playbook.yaml"
  content = "${data.template_file.db_restore_ansible_playbook.rendered}"
}

resource "aws_s3_bucket_object" "ssl_ansible_playbook" {
  bucket  = "${aws_s3_bucket_object.ssl_ansible_playbook.id}"
  key     = "ansible/openvpn_ssl_ansible_playbook.yaml"
  content = "${data.template_file.ssl_ansible_playbook.rendered}"
}

resource "aws_s3_bucket_object" "update_ansible_playbook" {
  bucket  = "${aws_s3_bucket_object.update_ansible_playbook.id}"
  key     = "ansible/openvpn_update_ansible_playbook.yaml"
  content = "${data.template_file.update_ansible_playbook.rendered}"
}