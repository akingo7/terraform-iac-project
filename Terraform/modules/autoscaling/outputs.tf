output "bastion_asg_name" {
  value = aws_autoscaling_group.bastion_asg.name
}

output "nginx_asg_name" {
  value = aws_autoscaling_group.nginx_asg.name
}

output "wordpress_asg_name" {
  value = aws_autoscaling_group.wordpress_asg.name
}

output "tooling_asg_name" {
  value = aws_autoscaling_group.tooling_asg.name
}
