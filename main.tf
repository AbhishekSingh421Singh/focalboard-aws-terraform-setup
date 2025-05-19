#Cloud Provider
provider "aws" {
  region = "us-east-1"
}

# VPC Module
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "focalBoard-VPC"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Public-Subnet"
  }
}
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Public-Subnet-B"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Security Group with dynamic block
resource "aws_security_group" "instance_sg" {
  name   = "instance-sg"
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-SG"
  }
}

resource "aws_lb"  "app_lb_open" {
  name               = "focalboard-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_b.id]
}

# ALB Target Groups
resource "aws_lb_target_group" "focalboard_tg" {
  name     = "focalboard-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# ALB Listener & Rules for focalboard
resource "aws_lb_listener" "listener_focalboard" {
  load_balancer_arn = aws_lb.app_lb_open.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.focalboard_tg.arn
  }
}

# EC2 Instance - FocalBoard
resource "aws_instance" "focalboard" {
  ami           = "ami-084568db4383264d4"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOT
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -dit -p 8000:8000 mattermost/focalboard
              EOT

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Name", "default")}-FocalBoard"
  })
}

# Register Targets
resource "aws_lb_target_group_attachment" "focal_board_attachment" {
  target_group_arn = aws_lb_target_group.focalboard_tg.arn
  target_id        = aws_instance.focalboard.id
  port             = 8000
}