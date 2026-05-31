output "ext_alb_dns_name" {
  value = aws_lb.ext_alb.dns_name
}

output "ext_alb_zone_id" {
  value = aws_lb.ext_alb.zone_id
}

output "nginx_target_group_arn" {
  value = aws_lb_target_group.nginx_tgt.arn
}

output "wordpress_target_group_arn" {
  value = aws_lb_target_group.wordpress_tgt.arn
}

output "tooling_target_group_arn" {
  value = aws_lb_target_group.tooling_tgt.arn
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.steghub.certificate_arn
}
