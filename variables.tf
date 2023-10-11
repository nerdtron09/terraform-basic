variable "vpc" {
  type = object({
    cidr_block             = string
    public_subnet_1_cidr   = string
    public_subnet_2_cidr   = string
    private_subnet_1_cidr  = string
    private_subnet_2_cidr  = string
    name_tag               = string
  })
}

variable "bastion" {
  type = object({
    ssh_whitelist         = list(string)
    ami                   = string
    instance_type         = string
    key_pair              = string
    name_tag              = string
  })
}

variable "private_ec2" {
  type = object({
    ssh_whitelist         = list(string)
    ami                   = string
    instance_type         = string
    key_pair              = string
    name_tag              = string
  })
}

variable "EC2_role" {
  type = object({
    name                  = string
    managed_policy_arns   = list(string)
  })
}

# variable "launchconfig" {
#   type = object({
#     image_id              = string
#     instance_type         = string
#     key_pair              = string
#     userdata_path         = string
#     name_prefix           = string
#     })
# }

# variable "asg" {
#   type = object({
#     min_size              = number
#     max_size              = number
#     desired_capacity      = number
#     hc_grace_period       = number
#     name_tag              = string
#     })
#   default = {
#     min_size              = 2
#     max_size              = 2
#     desired_capacity      = 2
#     hc_grace_period       = 300
#     name_tag = ""
#     }
# }

variable "igw_name_tag" {
  type = string
}

variable "public_subnet_1_name_tag" {
  type = string
}

variable "public_subnet_2_name_tag" {
  type = string
}

variable "private_subnet_1_name_tag" {
  type = string
}

variable "private_subnet_2_name_tag" {
  type = string
}

variable "eip_nat_name_tag" {
  type = string
}

variable "ngw_name_tag" {
  type = string
}

variable "public_rt_name_tag" {
  type = string
}

variable "private_rt_name_tag" {
  type = string
}

variable "bastion_sg_name_tag" {
  type = string
}

variable "private_sg_name_tag" {
  type = string
}

# variable "alb_sg_name_tag" {
#   type = string
# }

# variable "alb_name_tag" {
#   type = string
# }

# variable "targetgrp_name_tag" {
#   type = string
# }

variable "GBL_CLASS_0_value" {
  type = string
}

variable "GBL_CLASS_1_value" {
  type = string
}










