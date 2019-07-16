resource "aws_rds_cluster_instance" "db_instance" {
  count                             = 1
  identifier                        = "openvpn-database-instance"
  cluster_identifier                = "${aws_rds_cluster.db_cluster.id}"
  instance_class                    = "${var.db_instance_type}"
  publicly_accessible               = false
  db_subnet_group_name              = "${aws_db_subnet_group.db_subnet_group.id}"
  tags = "${merge(var.common_tags,
    map("Name", "${var.environment}-OPENVPN-DB")
  )}"
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier                = "openvpn-database-cluster"
  database_name                     = "openvpndb"
  availability_zones                = ["${data.aws_availability_zones.available.names[0]}","${data.aws_availability_zones.available.names[1]}"]
  master_username                   = "${var.rds_master_name}"
  master_password                   = "${var.rds_master_password}"
  final_snapshot_identifier         = "openvpn-db-snapshot-final"
  backup_retention_period           = "${var.rds_backup_retention_period }"
  preferred_backup_window           = "${var.rds_preferred_backup_window }"
  preferred_maintenance_window      = "${var.rds_maintenance_window}"
  port                              = "3306"
  db_subnet_group_name              = "${aws_db_subnet_group.db_subnet_group.id}"
  vpc_security_group_ids            = ["${aws_security_group.openvpn-rds-sg.id}"]
  storage_encrypted                 = "${var.rds_storage_encrypted}"
  tags = "${merge(var.common_tags,
    map("Name", "${var.environment}-OPENVPN-RDS-Cluster")
  )}"
}