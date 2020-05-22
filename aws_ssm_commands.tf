data "aws_instances" "nodes" {
  depends_on = [aws_autoscaling_group.openvpn]
  instance_tags = {
    Name = "${upper(var.environment)}-OPENVPN-EC2-ASG"
  }
  instance_state_names = ["running"]
}

data "aws_instance" "asg-openvpn-instances" {
  count       = aws_autoscaling_group.openvpn.desired_capacity
  depends_on  = [data.aws_instances.nodes]
  instance_id = data.aws_instances.nodes.ids[count.index]
}

resource "aws_ssm_association" "db_ansible_playbook" {
  count            = var.run_db_migration_playbook ? 1 : 0
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "db_ansible_playbook"

  schedule_expression = "rate(30 minutes)"

  targets {
    key    = "tag:Name"
    values = ["${upper(var.environment)}-OPENVPN-EC2"]
  }

  parameters = {
    playbook = data.template_file.db_ansible_playbook.rendered
  }

  output_location {
    s3_bucket_name = aws_s3_bucket.ssm_ansible_bucket.id
    s3_key_prefix  = "logs"
  }
}

resource "aws_ssm_association" "ssl_ansible_playbook" {
  count            = var.run_ssl_playbook ? 1 : 0
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "ssl_ansible_playbook"

  schedule_expression = "cron(55 23 31 12 ? *)"

  targets {
    key    = "tag:Name"
    values = ["${upper(var.environment)}-OPENVPN-EC2"]
  }

  parameters = {
    playbook = data.template_file.ssl_ansible_playbook.rendered
  }

  output_location {
    s3_bucket_name = aws_s3_bucket.ssm_ansible_bucket.id
    s3_key_prefix  = "logs"
  }
}

resource "aws_ssm_association" "update_ansible_playbook" {
  count            = var.run_update_server_playbook ? 1 : 0
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "update_server_ansible_playbook"

  schedule_expression = "cron(55 22 ? * SUN *)"

  targets {
    key    = "tag:Name"
    values = ["${upper(var.environment)}-OPENVPN-EC2"]
  }

  parameters = {
    playbook = data.template_file.update_ansible_playbook.rendered
  }

  output_location {
    s3_bucket_name = aws_s3_bucket.ssm_ansible_bucket.id
    s3_key_prefix  = "logs"
  }
}