provider "aws" {
  region = var.aws_region
}

#############################
# EC2 Instance
#############################
resource "aws_instance" "web" {
  ami           = "ami-021a584b49225376d"
  instance_type = "t2.medium"
  subnet_id     = element(var.subnet_ids, 0)
  key_name      = "awsdevops"

  tags = {
    Name        = "app-${var.environment}"
    Environment = var.environment
  }
}

#############################
# Security Group (Allow HTTP)
#############################
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP"
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

#############################
# Application Load Balancer
#############################
resource "aws_lb" "app_alb" {
  name               = "app-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  tags = {
    Environment = var.environment
  }
}

#############################
# Target Group
#############################
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

#############################
# Attach Instance to Target Group
#############################
resource "aws_lb_target_group_attachment" "attach_app" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

#############################
# Listener (on port 80)
#############################
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Default response"
      status_code  = "200"
    }
  }
}

#############################
# Listener Rule (for Blue/Green)
#############################
resource "aws_lb_listener_rule" "bluegreen_weight" {
  listener_arn = aws_lb_listener.my_listener.arn
  priority     = var.environment == "blue" ? 100 : 200

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.app_tg.arn
        weight = var.environment == "blue" ? 100 : 0
      }
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}