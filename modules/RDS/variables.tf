variable "private_data_subnet_ids" {
  type = list(string)
}

variable "datalayer_sg_id" {
  type = string
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "storage_type" {
  type    = string
  default = "gp2"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "engine_version" {
  type    = string
  default = "8.4.8"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "parameter_group_name" {
  type    = string
  default = "default.mysql8.4"
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "db_subnet_group_name" {
  type    = string
  default = "acs-rds"
}

variable "db_subnet_group_tag_name" {
  type    = string
  default = "ACS-rds"
}

variable "db_instance_tag_name" {
  type    = string
  default = "steghub-rds"
}
