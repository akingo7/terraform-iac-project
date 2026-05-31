locals {
  bucket_name = lower(join("-", [var.name, "bucket", var.region, var.account_no]))
}

variable "cidr_block" {
  description = "vpc cidr block"
  default     = "172.16.0.0/16"
}

variable "enable_dns_support" {
  description = "vpc dns support"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "vpc dns hostnames"
  default     = true
}

variable "region" {
  description = "aws region"
  default     = "eu-central-1"
}

variable "preferred_number_of_public_subnets" {
  description = "preferred number of public subnets"
  default     = null
  type        = number
}

variable "preferred_number_of_private_subnets" {
  description = "preferred number of private subnets"
  default     = null
  type        = number
}


variable "name" {
  type    = string
  default = "ACS"

}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}


variable "ami" {
  type        = string
  description = "AMI ID for the launch template"
}


variable "keypair" {
  type        = string
  description = "key pair for the instances"
}

variable "account_no" {
  type        = number
  description = "the account number"
}

variable "username" {
  type        = string
  description = "the username for the IAM user"
}


variable "master-username" {
  type        = string
  description = "RDS admin username"
}

variable "master-password" {
  type        = string
  description = "RDS master password"
}