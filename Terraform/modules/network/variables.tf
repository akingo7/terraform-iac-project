
variable "cidr_block" {
  description = "vpc cidr block"
  default     = "172.16.0.0/16"
}

variable "enable_dns_support" {
  description = "vpc dns support"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "vpc dns hostnames"
  type        = bool
}

variable "preferred_number_of_public_subnets" {
  description = "preferred number of public subnets"
  type        = number
}

variable "preferred_number_of_private_subnets" {
  description = "preferred number of private subnets"
  type        = number
}

variable "name" {
  description = "Resource name prefix"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}