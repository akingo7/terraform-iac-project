variable "ami" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "bastion_sg_id" {
  type = string
}

variable "nginx_sg_id" {
  type = string
}

variable "webserver_sg_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_web_subnet_ids" {
  type = list(string)
}

variable "nginx_target_group_arn" {
  type = string
}

variable "wordpress_target_group_arn" {
  type = string
}

variable "tooling_target_group_arn" {
  type = string
}

variable "bastion_user_data_base64" {
  type = string
}

variable "nginx_user_data_base64" {
  type = string
}

variable "wordpress_user_data_base64" {
  type = string
}

variable "tooling_user_data_base64" {
  type = string
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
