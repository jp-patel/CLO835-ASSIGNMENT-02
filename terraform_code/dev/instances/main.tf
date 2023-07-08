# # # # # # # # # # # # # # # # #
# CLO835 week_09 assignment_02  #
# Jal Patel                     #
# 118198225                     #
# # # # # # # # # # # # # # # # #

#Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Data block to retrieve the default VPC id 
data "aws_vpc" "default" {
  default = true

  # tags = {
  #   Name = "default vpc"
  # }
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}_${var.env}"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}

# Defining AWS EC2 instance
resource "aws_instance" "CLO835_week_09_assignment_02_ec2_linux" {
  # ami                                = "ami-0715c1897453cabd1"
  ami      = data.aws_ami.latest_amazon_linux.id
  key_name = aws_key_pair.key_pair_jal_patel.key_name
  # instance_type                      = "t2.micro"
  instance_type = lookup(var.instance_type, var.env)
  # subnet_id                          = aws_subnet.CLO835_week_09_assignment_02_subnet_01.id
  # security_groups             = [aws_security_group.CLO835_week_09_assignment_02_sg.id]
  vpc_security_group_ids      = [aws_security_group.CLO835_week_09_assignment_02_sg.id]
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

  # tags = {
  #   Name = "EC2 Instance for CLO835_week_09_assignment_02"
  # }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Amazon-Linux"
    }
  )
}

# Defining the kay pair
resource "aws_key_pair" "key_pair_jal_patel" {
  key_name   = "CLO835_assignment_02"
  public_key = file("${local.name_prefix}.pub")
}

# provisioning a public subnet in the default VPC
# resource "aws_subnet" "CLO835_week_09_assignment_02_subnet_01" {
#   vpc_id            = data.aws_vpc.default
#   cidr_block        = "172.31.0.0/24"
#   availability_zone = "us-east-1a"

#   map_public_ip_on_launch = true

#   tags = {
#     Name = "CLO835_week_09_assignment1_Subnet"
#   }
# }

# security group creation
resource "aws_security_group" "CLO835_week_09_assignment_02_sg" {
  name        = "CLO835_week_09_assignment_02_security_group"
  description = "Security group for CLO835 week 04 assignment 01"

  vpc_id = data.aws_vpc.default.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # ingress {
  #   description      = "HTTP from everywhere"
  #   from_port        = 8081
  #   to_port          = 8081
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  # ingress {
  #   description      = "HTTP from everywhere"
  #   from_port        = 8082
  #   to_port          = 8082
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  # ingress {
  #   description      = "HTTP from everywhere"
  #   from_port        = 8083
  #   to_port          = 8083
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecr_repository" "CLO835_week_09_assignment_02_ecr_APP_repository" {
  name = "clo835_week_09_assignment1_app"
}

resource "aws_ecr_repository" "CLO835_week_09_assignment_02_ecr_DB_repository" {
  name = "clo835_week_09_assignment1_db"
}

# Elastic IP
resource "aws_eip" "CLO835_week_09_assignment_02_static_eip" {
  instance = aws_instance.CLO835_week_09_assignment_02_ec2_linux.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}_eip"
    }
  )
}