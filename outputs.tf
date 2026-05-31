output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "alb_dns_name" {
  value = module.alb.ext_alb_dns_name
}

output "nginx_target_group_arn" {
  value = module.alb.nginx_target_group_arn
}

output "backend_bucket_name" {
  value = module.compute.backend_bucket_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
