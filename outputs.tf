output "rds_cluster" {
  value = aws_rds_cluster.db_cluster.id
}

output "aws_rds_cluster_instance_endpoint" {
  value = aws_rds_cluster_instance.db_instance[0].endpoint
}

output "aws_rds_instance_port" {
  value = aws_rds_cluster_instance.db_instance[0].port
}

output "openvpn_public_ip" {
  value = aws_eip.openvpn[0].id
}