data "aws_ami" "nginx" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-youtube-demo*"]
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
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "nginx-instance-sg"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "blue_instance" {
  ami                         = data.aws_ami.nginx.id
  instance_type               = "t2.micro"
  key_name                    = "aws-learning-env"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  subnet_id                   = var.subnets[0]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "nginx-blue-instance"
  }
}

resource "aws_instance" "green_instance" {
  ami                         = data.aws_ami.nginx.id
  instance_type               = "t2.micro"
  key_name                    = "aws-learning-env"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  subnet_id                   = var.subnets[0]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "nginx-green-instance"
  }
}

resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nginx_tg_blue" {
  name     = "nginx-tg-blue"
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

resource "aws_lb_target_group" "nginx_tg_green" {
  name     = "nginx-tg-green"
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

resource "aws_lb_target_group_attachment" "blue_attachment" {
  target_group_arn = aws_lb_target_group.nginx_tg_blue.arn
  target_id        = aws_instance.blue_instance.id
  port             = 80
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "green_attachment" {
  target_group_arn = aws_lb_target_group.nginx_tg_green.arn
  target_id        = aws_instance.green_instance.id
  port             = 80
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg_blue.arn
  }
}

resource "aws_lb_listener_rule" "blue_green_rule" {
  listener_arn = aws_lb_listener.nginx_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg_green.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
