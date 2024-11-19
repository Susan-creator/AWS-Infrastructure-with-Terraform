# VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
}

# Subnets
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Route Table and Associations
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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
    Name = "WebSG"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "test-s3bucket-sue8"
}

# IAM Role for S3 Access
resource "aws_iam_role" "ec2_s3_role" {
  name = "EC2S3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "EC2S3Role"
  }
}

# IAM Policy to Access S3
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow S3 access for EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name = "S3AccessPolicy"
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_s3_role.name

  tags = {
    Name = "InstanceProfile"
  }
}

# EC2 Instances
resource "aws_instance" "webserver1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sub1.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("userdata.sh")

  # Attach IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "WebServer1"
  }
}

resource "aws_instance" "webserver2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sub2.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("userdata1.sh")

  # Attach IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "WebServer2"
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.web_sg.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "WebALB"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name      = "mytg"
  port      = 80
  protocol  = "HTTP"
  vpc_id    = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

# Output for ALB DNS
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
