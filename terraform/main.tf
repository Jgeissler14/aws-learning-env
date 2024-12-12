
data "aws_ami" "nginx" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-youtube-demo"]
  }
}


resource "aws_security_group" "lb_sg" {
  name_prefix = "nginx-lb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "instance" {
  ami                         = data.aws_ami.nginx.id
  instance_type               = "t2.micro"
  key_name                    = "aws-learning-env"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.lb_sg.id]
  availability_zone           = var.AWS_REGION

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "nginx-instance"
  }
}


resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-1", "subnet-2"]

  enable_deletion_protection = false
}


resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-12345678"

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }
}


resource "aws_lb_target_group_attachment" "nginx_attachment" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.instance.id
  port             = 80
}


resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

