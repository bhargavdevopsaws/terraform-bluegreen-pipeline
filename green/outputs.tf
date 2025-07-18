output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "instance_public_ip" {
  value = length(aws_instance.web) > 0 ? aws_instance.web[0].public_ip : ""
}
