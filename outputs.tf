output "alb_dns_name" {
  value = aws_lb.app_lb_open.dns_name
}

output "focalboard_instance_ip" {
  value = aws_instance.focalboard.public_ip
}