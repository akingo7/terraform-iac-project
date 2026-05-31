locals {
  source_ingress_rules = {
    inbound_nginx_http = {
      from_port     = 443
      to_port       = 443
      protocol      = "tcp"
      source_sg_key = "ext_alb"
      target_sg_key = "nginx"
    }
    inbound_bastion_ssh_nginx = {
      from_port     = 22
      to_port       = 22
      protocol      = "tcp"
      source_sg_key = "bastion"
      target_sg_key = "nginx"
    }
    inbound_ialb_https = {
      from_port     = 443
      to_port       = 443
      protocol      = "tcp"
      source_sg_key = "nginx"
      target_sg_key = "int_alb"
    }
    inbound_web_https = {
      from_port     = 443
      to_port       = 443
      protocol      = "tcp"
      source_sg_key = "int_alb"
      target_sg_key = "webserver"
    }
    inbound_web_ssh = {
      from_port     = 22
      to_port       = 22
      protocol      = "tcp"
      source_sg_key = "bastion"
      target_sg_key = "webserver"
    }
    inbound_nfs_port = {
      from_port     = 2049
      to_port       = 2049
      protocol      = "tcp"
      source_sg_key = "webserver"
      target_sg_key = "datalayer"
    }
    inbound_mysql_bastion = {
      from_port     = 3306
      to_port       = 3306
      protocol      = "tcp"
      source_sg_key = "bastion"
      target_sg_key = "datalayer"
    }
    inbound_mysql_webserver = {
      from_port     = 3306
      to_port       = 3306
      protocol      = "tcp"
      source_sg_key = "webserver"
      target_sg_key = "datalayer"
    }
  }
}

resource "aws_security_group" "ext_alb_sg" {
  name        = "ext-alb-sg"
  vpc_id      = var.vpc_id
  description = "Allow TLS inbound traffic"

  dynamic "ingress" {
    for_each = var.ext_alb_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.default_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = "ext-alb-sg" })
}

resource "aws_security_group" "bastion_sg" {
  name        = "vpc_web_sg"
  vpc_id      = var.vpc_id
  description = "Allow incoming HTTP connections."

  dynamic "ingress" {
    for_each = var.bastion_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.default_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = "Bastion-SG" })
}

resource "aws_security_group" "nginx_sg" {
  name   = "nginx-sg"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.default_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = "nginx-SG" })
}

resource "aws_security_group" "int_alb_sg" {
  name   = "my-alb-sg"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.default_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = "int-alb-sg" })
}

resource "aws_security_group" "webserver_sg" {
  name   = "my-asg-sg"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.default_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = "webserver-sg" })
}

resource "aws_security_group" "datalayer_sg" {
  name   = "datalayer-sg"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.default_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = "datalayer-sg" })
}

locals {
  sg_ids = {
    ext_alb   = aws_security_group.ext_alb_sg.id
    bastion   = aws_security_group.bastion_sg.id
    nginx     = aws_security_group.nginx_sg.id
    int_alb   = aws_security_group.int_alb_sg.id
    webserver = aws_security_group.webserver_sg.id
    datalayer = aws_security_group.datalayer_sg.id
  }
}

resource "aws_security_group_rule" "source_ingress" {
  for_each = local.source_ingress_rules

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = local.sg_ids[each.value.source_sg_key]
  security_group_id        = local.sg_ids[each.value.target_sg_key]
}
