resource "aws_rds_cluster_instance" "db_instance" {
  count                = 1
  identifier           = var.rds_instance_name
  cluster_identifier   = aws_rds_cluster.db_cluster.id
  instance_class       = var.db_instance_type
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  tags = merge(
    var.common_tags,
    {
      "Name" = "${upper(var.environment)}-OPENVPN-DB"
    },
  )

  lifecycle {
    ignore_changes = [cluster_identifier]
  }
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier           = var.rds_cluster_identifier
  snapshot_identifier          = var.snapshot_identifier
  database_name                = var.rds_database_name
  master_username              = var.rds_master_name
  master_password              = var.rds_master_password
  final_snapshot_identifier    = var.rds_final_snapshot
  backup_retention_period      = var.rds_backup_retention_period
  preferred_backup_window      = var.rds_preferred_backup_window
  preferred_maintenance_window = var.rds_maintenance_window
  port                         = var.rds_port
  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids       = [aws_security_group.openvpn-rds-sg.id]
  storage_encrypted            = var.rds_storage_encrypted
  apply_immediately            = var.apply_immediately
  deletion_protection          = var.deletion_protection
  tags = merge(
    var.common_tags,
    {
      "Name" = "${upper(var.environment)}-OPENVPN-RDS-Cluster"
    },
  )
}