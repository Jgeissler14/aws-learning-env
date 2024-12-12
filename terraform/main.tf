data "aws_ami" "nginx" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-youtube-demo*"]
  }
}

# Security Group for Load Balancer (Public access on port 80)
resource "aws_security_group" "lb_sg" {
  name_prefix = "nginx-lb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allowing public access to the LB on port 80
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for EC2 instance (Allow traffic from LB security group on port 80)
resource "aws_security_group" "instance_sg" {
  name_prefix = "nginx-instance-sg"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]  # Only allow traffic from the LB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "instance" {
  ami                         = data.aws_ami.nginx.id
  instance_type               = "t2.micro"
  key_name                    = "aws-learning-env"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  subnet_id                   = var.subnets[0]  # Ensure this is set to a public subnet

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "nginx-instance"
  }
}

# Load Balancer
resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnets  # Ensure this points to public subnets

  enable_deletion_protection = false
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }
}

# Attach EC2 instance to Load Balancer target group
resource "aws_lb_target_group_attachment" "nginx_attachment" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.instance.id
  port             = 80
}

# Load Balancer Listener (for HTTP)
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

