variable "db_instance_type" {
  type = "string"
  default = "db.t2.small"
}

variable "rds_master_name" {
  type = "string"
}

variable "rds_master_password" {
  type = "string"
}

variable "rds_backup_retention_period" {
  type = "string"
  default = "7"
}

variable "rds_preferred_backup_window" {
  type = "string"
  default = "01:00-03:00"
}

variable "rds_maintenance_window" {
  type = "string"
  default = "sun:03:00-sun:04:00"
}

variable "rds_storage_encrypted" {
  default = true
}

variable "key_name" {
  type = "string"
  description = "Set the EC2 Key name"
}

variable "ec2_image_id" {
  description = "Set the AMI ID user for the Launch Configuration"
}

variable "ec2_instance_type" {
  type = "string"
  description = "Set EC2 instance type for Openvpn server"
  default = "t2.small"
}

variable "r53_domain_name" {
  description = "Set the domain name of your OpenVPN deployment"
}

variable "r53_hosted_zone_id" {
  description = "Set the hosted zone id"
}

variable "environment" {}

variable "vpc_id" {
  type = "string"
}

variable "vpc_cidr_range" {
  type = "string"
}

variable "common_tags" {
  type = "map"
}

variable "aws_region" {}

variable "s3_bucket_acl" {
  default = "private"
}

variable "s3_bucket_force_destroy" {}
variable "s3_bucket_name_ansible" {}
variable "s3_bucket_name_output" {}
variable "s3_bucket_policy" {}

locals {
  environment = "${substr(var.common_tags["Environment"],0,1)}"
}

variable "bucket_versioning" {
  default = false
}

variable "s3_sse_algorithm" {
  default = "AES256"
}