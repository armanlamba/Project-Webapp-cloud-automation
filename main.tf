terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}


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
# VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Prod VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.1.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 3"
  }
}
resource "aws_subnet" "public_subnet_4" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.1.4.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 4"
  }
}
# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.1.5.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.1.6.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet 2"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "NAT Gateway"
  }
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_association_4" {
  subnet_id      = aws_subnet.public_subnet_4.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Security Group"
  }
}

# EC2 Instances
resource "aws_instance" "web1" {
  ami             = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.keypair1.key_name
  subnet_id       = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    Name = "WebServer1"
  }
}

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.latest_amazon_linux.id 
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.keypair1.key_name
  subnet_id       = aws_subnet.public_subnet_2.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_instance" "web3" {
  ami             = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.keypair1.key_name
  subnet_id       = aws_subnet.public_subnet_3.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    Name = "WebServer3"
  }
}


resource "aws_instance" "web4" {
  ami             = data.aws_ami.latest_amazon_linux.id # Replace with the AMI ID of your choice
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.keypair1.key_name 
  subnet_id       = aws_subnet.public_subnet_4.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    Name = "WebServer4"
  }
}

resource "aws_instance" "web5" {
  ami             = data.aws_ami.latest_amazon_linux.id # Replace with the AMI ID of your choice
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.keypair1.key_name
  subnet_id       = aws_subnet.private_subnet_1.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    Name = "WebServer5"
  }
}

resource "aws_instance" "vm6" {
  ami             = data.aws_ami.latest_amazon_linux.id # Replace with the AMI ID of your choice
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.keypair1.key_name
  subnet_id       = aws_subnet.private_subnet_2.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    Name = "VM6"
  }
}

resource "aws_key_pair" "keypair1" {
  key_name   = "keypair1"
  public_key = file("keypair1.pub")
}

# Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id
  ]

  enable_deletion_protection = false
  tags = {
    Name = "Web ALB"
  }
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod_vpc.id

  health_check {
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name = "Web Target Group"
  }
}

# ALB Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Register Web Servers to Target Group
resource "aws_lb_target_group_attachment" "web1_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.bastion.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web3_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web3.id
  port             = 80
}

# Output the Load Balancer DNS Name
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web_alb.dns_name
}
