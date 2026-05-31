variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ext_alb_sg_id" {
  type = string
}

variable "int_alb_sg_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "route53_zone_name" {
  type    = string
  default = "demo.steghub.com"
}

variable "certificate_domain" {
  type    = string
  default = "*.demo.steghub.com"
}

variable "tooling_record_name" {
  type    = string
  default = "tooling.demo.steghub.com"
}

variable "wordpress_record_name" {
  type    = string
  default = "wordpress.demo.steghub.com"
}

variable "tooling_host_header" {
  type    = string
  default = "tooling.demo.steghub.com"
}

variable "ext_alb_name" {
  type    = string
  default = "ext-alb"
}

variable "int_alb_name" {
  type    = string
  default = "ialb"
}

variable "ext_alb_tag_name" {
  type    = string
  default = "ACS-ext-alb"
}

variable "int_alb_tag_name" {
  type    = string
  default = "ACS-int-alb"
}

variable "nginx_target_group_name" {
  type    = string
  default = "nginx-tgt"
}

variable "wordpress_target_group_name" {
  type    = string
  default = "wordpress-tgt"
}

variable "tooling_target_group_name" {
  type    = string
  default = "tooling-tgt"
}
