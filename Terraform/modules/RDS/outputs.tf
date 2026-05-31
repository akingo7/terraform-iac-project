output "db_instance_identifier" {
  value = aws_db_instance.acs_rds.identifier
}

output "db_endpoint" {
  value = aws_db_instance.acs_rds.endpoint
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.acs_rds.name
}
