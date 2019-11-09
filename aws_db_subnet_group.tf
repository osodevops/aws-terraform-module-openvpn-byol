resource "aws_db_subnet_group" "db_subnet_group" {
  name        = var.rds_subnet_group
  description = "Allowed subnets for OpenVPN Aurora cluster instances"
  subnet_ids  = data.aws_subnet_ids.private.ids
  tags        = var.common_tags
}