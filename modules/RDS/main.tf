resource "aws_db_subnet_group" "acs_rds" {
  name       = var.db_subnet_group_name
  subnet_ids = [var.private_data_subnet_ids[0], var.private_data_subnet_ids[1]]

  tags = merge(var.tags, { Name = var.db_subnet_group_tag_name })
}

resource "aws_db_instance" "acs_rds" {
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.master_username
  password               = var.master_password
  parameter_group_name   = var.parameter_group_name
  db_subnet_group_name   = aws_db_subnet_group.acs_rds.name
  skip_final_snapshot    = var.skip_final_snapshot
  vpc_security_group_ids = [var.datalayer_sg_id]
  multi_az               = var.multi_az

  tags = merge(var.tags, { Name = var.db_instance_tag_name })
}
