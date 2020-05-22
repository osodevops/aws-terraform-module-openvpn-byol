resource "aws_launch_configuration" "openvpn_launch_config" {
  name_prefix                 = "${upper(var.environment)}-OPENVPN-ASG-"
  image_id                    = data.aws_ami.openvpn.id
  instance_type               = var.ec2_instance_type
  iam_instance_profile        = aws_iam_instance_profile.openvpn_profile.name
  security_groups             = [aws_security_group.openvpn-sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  user_data                   = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "openvpn" {
  name                 = "${upper(var.environment)}-OPENVPN-ASG"
  launch_configuration = aws_launch_configuration.openvpn_launch_config.name
  vpc_zone_identifier  = data.aws_subnet_ids.public.ids
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity

  lifecycle {
    create_before_destroy = true
  }

  tags = flatten(["${data.null_data_source.asg_tags.*.outputs}",
    map("key", "Name", "value", "${upper(var.environment)}-OPENVPN-EC2-ASG", "propagate_at_launch", true),
    map("key", "AWSInspectorEnabled", "value", "true", "propagate_at_launch", true),
  ])
}
