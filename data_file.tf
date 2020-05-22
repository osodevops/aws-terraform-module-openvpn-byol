data "template_file" "user_data" {
  template = file("${path.module}/scripts/user_data.sh")

  vars = {
    eip                       = aws_eip.openvpn[0].id
    eip_ip4                   = aws_eip.openvpn[0].public_ip
    region                    = var.aws_region
    domain_name               = var.r53_domain_name
    hosted_zone_id            = var.r53_hosted_zone_id
    s3_bucket                 = aws_s3_bucket.ssm_ansible_bucket.id
    ssm_parameter_name        = var.ssm_parameter_name
    private_network_access_1  = var.private_network_access_1
    private_network_access_2  = var.private_network_access_2
    tunnel_setting            = var.vpn_tunnel_setting
  }
}