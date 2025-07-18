locals {
  is_blue  = var.environment == "blue"
  is_green = var.environment == "green"
}

provider "aws" {
  region = "ap-south-1"
}

# =======================
# Security Group for ALB
# =======================
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.environment}"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

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

# =======================
# ALB
# =======================
resource "aws_lb" "app_alb" {
  name               = "alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  tags = {
    Environment = var.environment
  }
}

# =======================
# Target Group
# =======================
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Environment = var.environment
  }
}

# =======================
# Listener
# =======================
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# =======================
# Blue Deployment (EC2)
# =======================
resource "aws_instance" "web" {
  count         = local.is_blue ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, 0)
  key_name      = "awsdevops"

  vpc_security_group_ids = [aws_security_group.alb_sg.id]

  tags = {
    Name = "app-${var.environment}"
  }
}

resource "aws_lb_target_group_attachment" "attach_instance" {
  count            = local.is_blue ? 1 : 0
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web[0].id
  port             = 80
}

# =======================
# Green Deployment (ASG)
# =======================
resource "aws_launch_template" "app" {
  count         = local.is_green ? 1 : 0
  name_prefix   = "app-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-${var.environment}"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  count               = local.is_green ? 1 : 0
  name                = "asg-${var.environment}"
  desired_capacity    = var.asg_min_size
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.app[0].id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "app-${var.environment}"
    propagate_at_launch = true
  }
}
