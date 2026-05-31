output "key_name" {
  value = aws_key_pair.infrakey.key_name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ip.name
}

output "backend_bucket_name" {
  value = aws_s3_bucket.backend_bucket.bucket
}
