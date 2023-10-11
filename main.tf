provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc.cidr_block

  tags = {
    Name = var.vpc.name_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name_tag
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.public_subnet_1_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_1_name_tag
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.public_subnet_2_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_2_name_tag
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.private_subnet_1_cidr
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = var.private_subnet_1_name_tag
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.private_subnet_2_cidr
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = var.private_subnet_2_name_tag
  }
}

resource "aws_eip" "nat" {
  tags = {
    "Name" : var.eip_nat_name_tag
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id           = aws_eip.nat.id
  subnet_id               = aws_subnet.public_subnet_2.id

  tags = {
    Name          = var.ngw_name_tag,
    "GBL_CLASS_0" = var.GBL_CLASS_0_value,
    "GBL_CLASS_1" = var.GBL_CLASS_1_value
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt_name_tag
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = var.private_rt_name_tag 
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "bastion" {
  ami                    = var.bastion.ami
  instance_type          = var.bastion.instance_type
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = var.bastion.key_pair
  iam_instance_profile   = aws_iam_instance_profile.EC2_profile.name
  
  tags = {
    Name = var.bastion.name_tag,
    "GBL_CLASS_0" = var.GBL_CLASS_0_value
    "GBL_CLASS_1" = var.GBL_CLASS_1_value  
  }
}

resource "aws_security_group" "bastion_sg" {
  name          = "bastion-security-group"
  description   = "Allow SSH from my IP"
  vpc_id        = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion.ssh_whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.bastion_sg_name_tag
  }
}

resource "aws_instance" "private_ec2" {
  ami                    = var.private_ec2.ami
  instance_type          = var.private_ec2.instance_type
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  subnet_id              = aws_subnet.private_subnet_1.id
  key_name               = var.private_ec2.key_pair
  iam_instance_profile   = aws_iam_instance_profile.EC2_profile.name
  
  tags = {
    Name = var.private_ec2.name_tag,
    "GBL_CLASS_0" = var.GBL_CLASS_0_value
    "GBL_CLASS_1" = var.GBL_CLASS_1_value  
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-security-group"
  description = "Allow traffic to private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.private_sg_name_tag
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions       = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "EC2_role" {
  name                = var.EC2_role.name
  assume_role_policy  = data.aws_iam_policy_document.instance-assume-role-policy.json
  managed_policy_arns = var.EC2_role.managed_policy_arns
}

resource "aws_iam_instance_profile" "EC2_profile" {
  name = "EC2-instance-profile"
  role = aws_iam_role.EC2_role.name
}


## Load Balancer
# resource "aws_lb" "alb" {
#   name               = var.alb_name_tag
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]
# }
# resource "aws_lb_target_group" "targetgrp" {
#   name        = var.targetgrp_name_tag
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "instance"
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn  = aws_lb.alb.arn
#   port               = "80"
#   protocol           = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.targetgrp.arn
#   }
# }

## ALB Security Group
# resource "aws_security_group" "alb_sg" {
#   name          = "alb-security-group"
#   description   = "Allow HTTP"
#   vpc_id        = aws_vpc.main.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     "Name" : var.alb_sg_name_tag
#   }
# }

## Launch configuration
# resource "aws_launch_configuration" "as_conf" {
#   name_prefix             = var.launchconfig.name_prefix
#   image_id                = var.launchconfig.image_id
#   instance_type           = var.launchconfig.instance_type
#   key_name                = var.launchconfig.key_pair
#   security_groups         = [aws_security_group.private_sg.id]
#   iam_instance_profile    = aws_iam_instance_profile.EC2_profile.name

#   lifecycle {
#     create_before_destroy = true
#   }

# 	user_data = file(var.launchconfig.userdata_path)
# }

## Auto Scaling Group
# resource "aws_autoscaling_group" "asg" {
#   name                      = var.asg.name_tag
#   launch_configuration      = aws_launch_configuration.as_conf.name
#   min_size                  = var.asg.min_size
#   max_size                  = var.asg.max_size
#   desired_capacity          = var.asg.desired_capacity
#   vpc_zone_identifier       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
#   health_check_type         = "ELB"
#   health_check_grace_period = var.asg.hc_grace_period
#   target_group_arns         = [aws_lb_target_group.targetgrp.arn]

#   lifecycle {
#     create_before_destroy   = true
#   }

#   tags = concat(
#     [
#       {
#         "key" = "GBL_CLASS_0",
#         "value" = var.GBL_CLASS_0_value,
#         "propagate_at_launch" = true
#       },
#       {
#         "key" = "GBL_CLASS_1",
#         "value" = var.GBL_CLASS_1_value,
#         "propagate_at_launch" = true
#       }
#     ]
#   )
# }








