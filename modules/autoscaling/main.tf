resource "aws_sns_topic" "default_cloudwatch_alarms_topic" {
  name = "Default_CloudWatch_Alarms_Topic"
}

resource "random_shuffle" "az_list" {
  input = var.availability_zones
}

resource "aws_launch_template" "bastion_launch_template" {
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.bastion_sg_id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  key_name = var.key_name

  placement {
    availability_zone = "random_shuffle.az_list.result"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "bastion-launch-template" })
  }

  user_data = var.bastion_user_data_base64
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                      = "bastion-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity

  vpc_zone_identifier = [
    var.public_subnet_ids[0],
    var.public_subnet_ids[1]
  ]

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bastion-launch-template"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "nginx_launch_template" {
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.nginx_sg_id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  key_name = var.key_name

  placement {
    availability_zone = "random_shuffle.az_list.result"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "nginx-launch-template" })
  }

  user_data = var.nginx_user_data_base64
}

resource "aws_autoscaling_group" "nginx_asg" {
  name                      = "nginx-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity

  vpc_zone_identifier = [
    var.public_subnet_ids[0],
    var.public_subnet_ids[1]
  ]

  launch_template {
    id      = aws_launch_template.nginx_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nginx-launch-template"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_nginx" {
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.id
  lb_target_group_arn    = var.nginx_target_group_arn
}

resource "aws_launch_template" "wordpress_launch_template" {
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.webserver_sg_id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  key_name = var.key_name

  placement {
    availability_zone = "random_shuffle.az_list.result"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "wordpress-launch-template" })
  }

  user_data = var.wordpress_user_data_base64
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "wordpress-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity

  vpc_zone_identifier = [
    var.private_web_subnet_ids[0],
    var.private_web_subnet_ids[1]
  ]

  launch_template {
    id      = aws_launch_template.wordpress_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wordpress-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_wordpress" {
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.id
  lb_target_group_arn    = var.wordpress_target_group_arn
}

resource "aws_launch_template" "tooling_launch_template" {
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.webserver_sg_id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  key_name = var.key_name

  placement {
    availability_zone = "random_shuffle.az_list.result"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "tooling-launch-template" })
  }

  user_data = var.tooling_user_data_base64
}

resource "aws_autoscaling_group" "tooling_asg" {
  name                      = "tooling-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity

  vpc_zone_identifier = [
    var.private_web_subnet_ids[0],
    var.private_web_subnet_ids[1]
  ]

  launch_template {
    id      = aws_launch_template.tooling_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "tooling-launch-template"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_tooling" {
  autoscaling_group_name = aws_autoscaling_group.tooling_asg.id
  lb_target_group_arn    = var.tooling_target_group_arn
}

resource "aws_autoscaling_notification" "notifications" {
  group_names = [
    aws_autoscaling_group.bastion_asg.name,
    aws_autoscaling_group.nginx_asg.name,
    aws_autoscaling_group.wordpress_asg.name,
    aws_autoscaling_group.tooling_asg.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.default_cloudwatch_alarms_topic.arn
}
