# Terraform AWS Web Server Assignment

## Objective

The objective of this project is to create and manage a Linux web server in AWS using Terraform instead of manually creating the infrastructure through the AWS Console.

This project demonstrates Infrastructure as Code (IaC), Terraform variables, reusable modules, outputs, EC2 user data, security groups, Terraform state, and resource cleanup.

## What This Project Does

This Terraform project:

- Creates an AWS Security Group
- Allows HTTP traffic on port 80
- Creates an Ubuntu EC2 instance
- Uses a reusable EC2 Terraform module
- Installs Apache automatically using EC2 user data
- Creates a custom webpage
- Uses variables instead of hardcoding configuration
- Displays the EC2 instance ID, public IP, public DNS, and website URL
- Uses Terraform state to track the AWS resources
- Allows all created resources to be removed using `terraform destroy`

## Architecture

The basic architecture of the project is:

User / Browser
      |
      | HTTP Port 80
      v
AWS Security Group
      |
      v
EC2 Instance
      |
      v
Apache Web Server
      |
      v
Custom index.html

Terraform is used to create and manage the Security Group and EC2 instance.

## Project Structure

terraform-webserver/
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── user_data.sh
├── README.md
├── commands.txt
├── state-investigation.txt
├── .gitignore
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

## Terraform Files

### versions.tf

Defines the required Terraform version and AWS provider.

### providers.tf

Configures the AWS provider and AWS region.

### variables.tf

Defines variables used by the root Terraform configuration, including:

- AWS region
- EC2 instance type
- Instance name
- Allowed CIDR range

### terraform.tfvars

Provides values for the Terraform variables.

### main.tf

Creates the AWS Security Group, finds the Ubuntu AMI, and calls the reusable EC2 module.

### outputs.tf

Displays useful information after deployment, including:

- EC2 instance ID
- Public IP address
- Public DNS
- Website URL

### user_data.sh

Runs automatically when the EC2 instance starts.

The script:

1. Updates the package repository
2. Installs Apache
3. Creates the custom index.html page
4. Enables Apache
5. Starts the Apache service

### modules/ec2

This directory contains the reusable EC2 Terraform module.

The module receives values from the root Terraform configuration and creates the EC2 instance.

## Prerequisites

The following are required before running the project:

- AWS account
- Terraform installed
- AWS CLI installed
- AWS credentials or an IAM role with the required permissions

For this project, Terraform was executed from an Ubuntu EC2 instance using an IAM role.

AWS authentication was verified using:

```bash
aws sts get-caller-identity
