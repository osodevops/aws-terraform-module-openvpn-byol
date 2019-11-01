data "aws_instances" "nodes" {
  depends_on = [aws_autoscaling_group.openvpn]
  instance_tags = {
    Name = "${upper(var.environment)}-OPENVPN-EC2"
  }
  instance_state_names = ["running"]
}

data "aws_instance" "asg-openvpn-instances" {
  count       = aws_autoscaling_group.openvpn.desired_capacity
  depends_on  = [data.aws_instances.nodes]
  instance_id = data.aws_instances.nodes.ids[count.index]
}

data "template_file" "db_migration_ansible_playbook" {
  template = file("${path.module}/ansible/db_migration.yml")

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
  }
}

#to delay ssm assiociation till ansible is installed
resource "null_resource" "migration_ansible_delay" {
  count = var.run_playbook == "db_migration" ? 0 : 1

   triggers = {
     ans_instance_ids = join(",", data.aws_instances.nodes.*.id)
   }

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

#to delay ssm assiociation till ansible is installed
resource "null_resource" "ssl_ansible_delay" {
  count = var.run_playbook == "ssl" ? 0 : 1

  triggers = {
    ans_instance_ids = join(",", data.aws_instances.nodes.*.id)
  }

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

resource "aws_ssm_association" "db_migration_ansible_playbook" {
  count            = var.run_playbook == "db_migration" ? 0 : 1
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "db_migration_ansible_playbook"

  schedule_expression = "rate(30 minutes)"

  targets {
    key    = "tag:Name"
    values = ["${upper(var.environment)}-OPENVPN-EC2"]
  }

  parameters = {
    playbook = data.template_file.db_migration_ansible_playbook.rendered
  }

  output_location = {
    s3_bucket_name = "${aws_s3_bucket.ssm_ansible_bucket.id}"  
  }

  depends_on = [null_resource.migration_ansible_delay]
}

resource "aws_ssm_association" "ssl_ansible_playbook" {
  count            = var.run_playbook == "ssl" ? 0 : 1
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "ssl_ansible_playbook"

  schedule_expression = "rate(30 minutes)"

  targets {
    key    = "tag:Name"
    values = ["${upper(var.environment)}-OPENVPN-EC2"]
  }

  parameters = {
    playbook = data.template_file.ssl_ansible_playbook.rendered
  }

  output_location = {
    s3_bucket_name = "${aws_s3_bucket.ssm_ansible_bucket.id}"
  }

  depends_on = [null_resource.ssl_ansible_delay]
}