variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "terraform-webserver"
}

variable "allowed_cidr" {
  description = "CIDR allowed to access the Apache web server"
  type        = string
  default     = "0.0.0.0/0"
}

variable "webpage_title" {
  description = "Title displayed on the Apache webpage"
  type        = string
  default     = "Terraform Apache Web Server"
}

variable "webpage_message" {
  description = "Message displayed on the Apache webpage"
  type        = string
  default     = "Apache was deployed automatically using a reusable Terraform module."
}
