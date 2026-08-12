variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR allowed to access the web server"
  type        = string
}

variable "webpage_title" {
  description = "Title displayed on the webpage"
  type        = string
}

variable "webpage_message" {
  description = "Message displayed on the webpage"
  type        = string
}
