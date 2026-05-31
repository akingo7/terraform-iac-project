module "network" {
  source = "./modules/network"

  cidr_block                          = var.cidr_block
  enable_dns_support                  = var.enable_dns_support
  enable_dns_hostnames                = var.enable_dns_hostnames
  preferred_number_of_public_subnets  = var.preferred_number_of_public_subnets
  preferred_number_of_private_subnets = var.preferred_number_of_private_subnets
  name                                = var.name
  tags                                = var.tags
}

module "security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
  tags   = var.tags
}

module "compute" {
  source = "./modules/compute"

  name            = var.name
  region          = var.region
  account_no      = var.account_no
  keypair         = var.keypair
  public_key_path = "${path.root}/keys/infrakey.pub"
  tags            = var.tags
}

module "alb" {
  source = "./modules/ALB"

  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  ext_alb_sg_id         = module.security.ext_alb_sg_id
  int_alb_sg_id         = module.security.int_alb_sg_id
  tags                  = var.tags
  route53_zone_name     = var.route53_zone_name
  certificate_domain    = var.certificate_domain
  tooling_record_name   = var.tooling_record_name
  wordpress_record_name = var.wordpress_record_name
}

module "efs" {
  source = "./modules/EFS"

  account_no              = var.account_no
  username                = var.username
  private_data_subnet_ids = module.network.private_data_subnet_ids
  datalayer_sg_id         = module.security.datalayer_sg_id
  tags                    = var.tags
}

module "rds" {
  source = "./modules/RDS"

  private_data_subnet_ids = module.network.private_data_subnet_ids
  datalayer_sg_id         = module.security.datalayer_sg_id
  master_username         = var.master_username
  master_password         = var.master_password
  tags                    = var.tags
}

module "autoscaling" {
  source = "./modules/autoscaling"

  ami                        = lookup(var.ami_map, var.region)
  key_name                   = module.compute.key_name
  instance_profile_name      = module.compute.instance_profile_name
  availability_zones         = data.aws_availability_zones.available.names
  bastion_sg_id              = module.security.bastion_sg_id
  nginx_sg_id                = module.security.nginx_sg_id
  webserver_sg_id            = module.security.webserver_sg_id
  public_subnet_ids          = module.network.public_subnet_ids
  private_web_subnet_ids     = module.network.private_web_subnet_ids
  nginx_target_group_arn     = module.alb.nginx_target_group_arn
  wordpress_target_group_arn = module.alb.wordpress_target_group_arn
  tooling_target_group_arn   = module.alb.tooling_target_group_arn
  bastion_user_data_base64   = filebase64("${path.root}/bastion.sh")
  nginx_user_data_base64     = filebase64("${path.root}/nginx.sh")
  wordpress_user_data_base64 = filebase64("${path.root}/wordpress.sh")
  tooling_user_data_base64   = filebase64("${path.root}/tooling.sh")
  desired_capacity           = var.autoscaling_desired_capacity
  min_size                   = var.autoscaling_min_size
  max_size                   = var.autoscaling_max_size
  tags                       = var.tags
}
