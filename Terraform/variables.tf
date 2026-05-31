variable "region" {
  description = "aws region"
  type        = string
  default     = "eu-central-1"
}

variable "name" {
  type    = string
  default = "ACS"
}

variable "cidr_block" {
  description = "vpc cidr block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "enable_dns_support" {
  description = "vpc dns support"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "vpc dns hostnames"
  type        = bool
  default     = true
}

variable "preferred_number_of_public_subnets" {
  description = "preferred number of public subnets"
  type        = number
  default     = 2
}

variable "preferred_number_of_private_subnets" {
  description = "preferred number of private subnets"
  type        = number
  default     = 2
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

variable "ami_map" {
  description = "Region to AMI mapping"
  type        = map(string)
}

variable "keypair" {
  type        = string
  description = "key pair for the instances"
}

variable "account_no" {
  type        = string
  description = "the account number"
}

variable "username" {
  type        = string
  description = "the username for the IAM user"
}

variable "master_username" {
  type        = string
  description = "RDS admin username"
}

variable "master_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
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

variable "autoscaling_desired_capacity" {
  type    = number
  default = 1
}

variable "autoscaling_min_size" {
  type    = number
  default = 1
}

variable "autoscaling_max_size" {
  type    = number
  default = 2
}
