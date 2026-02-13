############################################
# Application Load Balancer
############################################

resource "aws_lb" "app_lb" {
  name               = "blue-green-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

  tags = {
    Name = "blue-green-alb"
  }
}

############################################
# Target Groups
############################################

resource "aws_lb_target_group" "blue_tg" {
  name     = "blue-target-group"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = "blue"
  }
}

resource "aws_lb_target_group" "green_tg" {
  name     = "green-target-group"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = "green"
  }
}

############################################
# Attach EC2 Instances to Target Groups
############################################

resource "aws_lb_target_group_attachment" "blue_attach" {
  target_group_arn = aws_lb_target_group.blue_tg.arn
  target_id        = aws_instance.blue.id
  port             = 5000
}

resource "aws_lb_target_group_attachment" "green_attach" {
  target_group_arn = aws_lb_target_group.green_tg.arn
  target_id        = aws_instance.green.id
  port             = 5000
}

############################################
# Listener (Blue-Green Switch)
############################################

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

    default_action {
    type = "forward"

    target_group_arn = (
        var.active_environment == "blue" ?
        aws_lb_target_group.blue_tg.arn :
        aws_lb_target_group.green_tg.arn
        )
    }
}
