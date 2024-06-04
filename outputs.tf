output "alb_endpoint" {
  description = "Public ALB DNS Name"
  value       = module.alb.dns_name
}

output "ec2_ip_address" {
  description = "EC2 IP Address"
  value       = tolist(data.aws_instances.demo.private_ips)[0]
}
