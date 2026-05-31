resource "aws_acm_certificate" "steghub" {
  domain_name       = var.certificate_domain
  validation_method = "DNS"
}

data "aws_route53_zone" "steghub" {
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "steghub_validation" {
  for_each = {
    for dvo in aws_acm_certificate.steghub.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.steghub.zone_id
}

resource "aws_acm_certificate_validation" "steghub" {
  certificate_arn         = aws_acm_certificate.steghub.arn
  validation_record_fqdns = [for record in aws_route53_record.steghub_validation : record.fqdn]
}

resource "aws_lb" "ext_alb" {
  name     = var.ext_alb_name
  internal = false
  security_groups = [
    var.ext_alb_sg_id
  ]

  subnets = [
    var.public_subnet_ids[0],
    var.public_subnet_ids[1]
  ]

  tags = merge(var.tags, { Name = var.ext_alb_tag_name })

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_target_group" "nginx_tgt" {
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = var.nginx_target_group_name
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.ext_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.steghub.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tgt.arn
  }
}

resource "aws_lb" "ialb" {
  name     = var.int_alb_name
  internal = true
  security_groups = [
    var.int_alb_sg_id
  ]

  subnets = [
    var.private_subnet_ids[0],
    var.private_subnet_ids[1]
  ]

  tags = merge(var.tags, { Name = var.int_alb_tag_name })

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_target_group" "wordpress_tgt" {
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = var.wordpress_target_group_name
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "tooling_tgt" {
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = var.tooling_target_group_name
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.ialb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.steghub.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tgt.arn
  }
}

resource "aws_lb_listener_rule" "tooling_listener" {
  listener_arn = aws_lb_listener.web_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tooling_tgt.arn
  }

  condition {
    host_header {
      values = [var.tooling_host_header]
    }
  }
}

resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.steghub.zone_id
  name    = var.tooling_record_name
  type    = "A"

  alias {
    name                   = aws_lb.ext_alb.dns_name
    zone_id                = aws_lb.ext_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.steghub.zone_id
  name    = var.wordpress_record_name
  type    = "A"

  alias {
    name                   = aws_lb.ext_alb.dns_name
    zone_id                = aws_lb.ext_alb.zone_id
    evaluate_target_health = true
  }
}
