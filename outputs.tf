output "instance_id" {
  description = "EC2 instance ID"
  value       = module.web_server.instance_id
}

output "public_ip" {
  description = "Public IPv4 address"
  value       = module.web_server.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = module.web_server.public_dns
}

output "website_url" {
  description = "Apache website URL"
  value       = "http://${module.web_server.public_ip}"
}
