output "efs_file_system_id" {
  value = aws_efs_file_system.acs_efs.id
}

output "wordpress_access_point_id" {
  value = aws_efs_access_point.wordpress.id
}

output "tooling_access_point_id" {
  value = aws_efs_access_point.tooling.id
}

output "kms_key_arn" {
  value = aws_kms_key.acs_kms.arn
}
