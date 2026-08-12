variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the EC2 instance"
  type        = string
}

variable "user_data" {
  description = "Startup script for the EC2 instance"
  type        = string
}
