vpc = {
    cidr_block             = "10.0.0.0/16"
    public_subnet_1_cidr   = "10.0.1.0/24"
    public_subnet_2_cidr   = "10.0.2.0/24"
    private_subnet_1_cidr  = "10.0.3.0/24"
    private_subnet_2_cidr  = "10.0.4.0/24"
    name_tag               = "P1-vpc-skillup"
}

bastion = {
    ssh_whitelist            = ["x.x.x.x/32"]
    ami                    = "ami-059b6d3840b03d6dd"
    instance_type          = "t2.micro"
    key_pair               = "skillup"
    name_tag               = "P1-bastion-skillup"
}

private_ec2 = {
    ssh_whitelist            = ["x.x.x.x/32"]
    ami                    = "ami-059b6d3840b03d6dd"
    instance_type          = "t2.micro"
    key_pair               = "skillup"
    name_tag               = "P1-private-skillup"
}

EC2_role = {
    name                   = "EC2-role-skillup"
    managed_policy_arns    = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
                              "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}

# launchconfig = {
#     image_id               = "ami-059b6d3840b03d6dd"
#     instance_type          = "t2.micro"
#     key_pair               = "skillup"
#     userdata_path          = "./scripts/install_apache.sh"
#     name_prefix            = "launchconfig-"
# }

# asg = {
#     min_size               = 2
#     max_size               = 2
#     desired_capacity       = 2
#     hc_grace_period        = 300
#     name_tag               = "asg-skillup"
# }

GBL_CLASS_0_value          = "SERVICE"
GBL_CLASS_1_value          = "test"

igw_name_tag               = "P1-igw-skillup"
public_subnet_1_name_tag   = "P1-public-subnet-skillup-1"
public_subnet_2_name_tag   = "P1-public-subnet-skillup-2"
private_subnet_1_name_tag  = "P1-private-subnet-skillup-1"
private_subnet_2_name_tag  = "P1-private-subnet-skillup-2"
eip_nat_name_tag           = "eip-nat-skillup"
ngw_name_tag               = "P1-nat-skillup"
public_rt_name_tag         = "P1-public-rt-skillup"
private_rt_name_tag        = "P1-private-rt-skillup"
bastion_sg_name_tag        = "P1-bastion-sg-skillup"
private_sg_name_tag        = "P1-private-sg-skillup"
# alb_sg_name_tag            = "P1-alb-sg-skillup"
# alb_name_tag               = "alb-skillup"
# targetgrp_name_tag         = "targetgrp-skillup"