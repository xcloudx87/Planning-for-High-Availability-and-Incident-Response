resource "aws_lb_target_group" "alb-tg" {
  name     = "udacity-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "alb-tg-att" {
  count            = 2
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = var.ec2.*.id[count.index]
  port             = 80
}

resource "aws_lb" "alb" {
  name               = "udacity-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.ec2_sg]
  subnets            = var.subnet_id
  enable_deletion_protection = false

}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}