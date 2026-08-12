variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name of the EC2 web server"
  type        = string
  default     = "terraform-webserver"
}

variable "allowed_cidr" {
  description = "CIDR allowed to access the Apache web server"
  type        = string
  default     = "0.0.0.0/0"
}
