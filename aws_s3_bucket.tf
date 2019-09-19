resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.s3_bucket_name}"
  policy        = "${var.s3_bucket_policy}"
  acl           = "${var.s3_bucket_acl}"
  force_destroy = "${var.s3_bucket_force_destroy}"

  versioning {
    enabled = "${var.bucket_versioning}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "${var.s3_sse_algorithm}"
      }
    }
  }

  tags = "${merge(var.common_tags,
    map("Name", "${local.environment}-${var.s3_bucket_name}-S3")
    )}"
}
