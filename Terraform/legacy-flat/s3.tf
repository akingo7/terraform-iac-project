resource "aws_s3_bucket" "backend_bucket" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = local.bucket_name
    },
  )
}