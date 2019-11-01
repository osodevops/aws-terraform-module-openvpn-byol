resource "aws_launch_configuration" "openvpn_launch_config" {
  name_prefix                 = "${upper(var.environment)}-OPENVPN-AS-"
  image_id                    = var.ec2_image_id
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
  name                 = "${upper(var.environment)}-OPENVPN-AS-ASG"
  launch_configuration = aws_launch_configuration.openvpn_launch_config.name
  vpc_zone_identifier  = data.aws_subnet_ids.public.ids
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "${upper(var.environment)}-OPENVPN-EC2"
      propagate_at_launch = true
    },
  ]
}

