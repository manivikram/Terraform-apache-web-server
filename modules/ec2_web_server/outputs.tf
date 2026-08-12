output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.web.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}

output "availability_zone" {
  description = "Availability zone"
  value       = aws_instance.web.availability_zone
}
