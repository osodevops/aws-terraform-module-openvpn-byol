data "template_file" "db_ansible_playbook" {
  template = file("${path.module}/ansible/db_tasks.yml")

  vars = {
    mariadb_repo_url          = var.mariadb_repo_url
    mariadb_repo_enable       = var.mariadb_repo_enable
    mariadb_repo_gpgcheck     = var.mariadb_repo_gpgcheck
    mariadb_repo_gpg_url      = var.mariadb_repo_gpg_url
    openvpn_database_user     = var.rds_master_name
    openvpn_database_password = var.rds_master_password
    openvpn_database_port     = var.rds_port
    openvpn_database_host     = aws_rds_cluster_instance.db_instance[0].endpoint
  }
}

data "template_file" "ssl_ansible_playbook" {
  template = file("${path.module}/ansible/ssl_automation.yml")

  vars = {
    openvpn_dns_name      = var.openvpn_dns_name
    ec2_hostname          = var.ec2_hostname
    ssl_admin_email       = var.ssl_admin_email
    epel_repofile_path    = var.epel_repofile_path
    epel_repo_gpg_key_url = var.epel_repo_gpg_key_url
    epel_repo_url         = var.epel_repo_url
    s3_bucket             = aws_s3_bucket.ssm_ansible_bucket.id
  }
}

data "template_file" "update_ansible_playbook" {
  template = file("${path.module}/ansible/server_update.yml")

  vars = {
    full_system_update    = var.run_full_system_update
  }
}