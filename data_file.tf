data "template_file" "user_data" {
  template = file("${path.module}/scripts/user_data.sh")

  vars = {
    eip            = aws_eip.openvpn[0].id
    eip_ip4        = aws_eip.openvpn[0].public_ip
    region         = var.aws_region
    domain_name    = var.r53_domain_name
    hosted_zone_id = var.r53_hosted_zone_id
  }
}