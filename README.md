# Terraform AWS Apache Web Server

## About This Project

I built this project as part of my Terraform hands-on practice. The goal was to deploy a working Apache web server in AWS without manually creating the infrastructure from the AWS Console.

I wanted the Terraform code to be reusable instead of writing everything in one `main.tf` file. So I created a separate `ec2_web_server` module that takes care of the EC2 instance, Security Group, Apache installation, storage configuration, and EC2 metadata security.

I ran Terraform from my Ubuntu EC2 environment and used an IAM role for AWS authentication instead of keeping AWS access keys inside the project.

By the end of the assignment, I was able to:

- Create the infrastructure using Terraform.
- Build a reusable EC2 web-server module.
- Install Apache automatically during EC2 startup.
- Generate a custom webpage from a Terraform template.
- Access the webpage using the EC2 public IP.
- Inspect the resources through Terraform state.
- Destroy the infrastructure after testing.
- Keep the complete Terraform configuration in GitHub.

---

# Architecture

This is the architecture I implemented:

```text
                         USER / BROWSER
                               |
                               |
                         HTTP Request
                           Port 80
                               |
                               v
                    +---------------------+
                    |      INTERNET       |
                    +----------+----------+
                               |
                               |
                               v
              +--------------------------------+
              |          AWS DEFAULT VPC       |
              |                                |
              |   +------------------------+   |
              |   |     SECURITY GROUP     |   |
              |   |                        |   |
              |   | Inbound: TCP 80        |   |
              |   | Source: allowed_cidr   |   |
              |   |                        |   |
              |   | Outbound: Allow All    |   |
              |   +-----------+------------+   |
              |               |                |
              |               | HTTP :80       |
              |               v                |
              |   +------------------------+   |
              |   |      EC2 INSTANCE      |   |
              |   |                        |   |
              |   |     Ubuntu Linux       |   |
              |   |          |             |   |
              |   |          v             |   |
              |   |       Apache2          |   |
              |   |          |             |   |
              |   |          v             |   |
              |   |    /var/www/html       |   |
              |   |      index.html        |   |
              |   |                        |   |
              |   |   IMDSv2 Required      |   |
              |   +-----------+------------+   |
              |               |                |
              |               v                |
              |   +------------------------+   |
              |   |     ROOT EBS VOLUME    |   |
              |   |                        |   |
              |   |       gp3              |   |
              |   |       Encrypted        |   |
              |   +------------------------+   |
              |                                |
              +--------------------------------+
```

The user accesses the EC2 public IP over HTTP.

The Security Group allows TCP port 80, and the request reaches Apache running inside the Ubuntu EC2 instance. Apache then serves the custom `index.html` page that was created automatically during instance startup.

---

# How Terraform Builds It

The infrastructure flow from the Terraform side looks like this:

```text
                    ROOT TERRAFORM CONFIG
                              |
              +---------------+---------------+
              |                               |
              v                               v
      Default VPC Lookup              Ubuntu AMI Lookup
      data.aws_vpc.default            data.aws_ami.ubuntu
              |                               |
              +---------------+---------------+
                              |
                              v
                   Input values passed to
                     reusable module
                              |
                              v
              +-------------------------------+
              |       ec2_web_server          |
              |            MODULE             |
              |                               |
              |  +-------------------------+  |
              |  |     Security Group      |  |
              |  +------------+------------+  |
              |               |               |
              |               v               |
              |  +-------------------------+  |
              |  |      EC2 Instance       |  |
              |  +------------+------------+  |
              |               |               |
              |               v               |
              |  +-------------------------+  |
              |  |  User Data Template     |  |
              |  |                         |  |
              |  | Install Apache          |  |
              |  | Create index.html       |  |
              |  | Start Apache            |  |
              |  +-------------------------+  |
              |                               |
              |  +-------------------------+  |
              |  | Encrypted gp3 EBS       |  |
              |  | IMDSv2 Required         |  |
              |  +-------------------------+  |
              +---------------+---------------+
                              |
                              v
                    TERRAFORM OUTPUTS
                              |
          +-------------------+--------------------+
          |          |           |        |        |
          v          v           v        v        v
      Instance    Public      Public     SG ID     AZ
         ID         IP          DNS
```

I kept the AWS provider, AMI lookup, VPC lookup and environment-specific values at the root level.

The actual web-server implementation is inside the module.

This means I can reuse the same module later and provide different values instead of rebuilding the EC2 configuration every time.

---

# Project Structure

My final repository is organized like this:

```text
Terraform-apache-web-server/
│
├── README.md
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── commands.txt
├── state-investigation.txt
├── .gitignore
├── .terraform.lock.hcl
│
└── modules/
    └── ec2_web_server/
        │
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        │
        └── templates/
            └── user_data.sh.tftpl
```

I kept the root configuration separate from the module so that the module contains the actual web-server logic while the root configuration decides what values should be passed to it.

---

# What Each File Does

## Root Configuration

### `providers.tf`

I use this file to configure the AWS provider.

The AWS region comes from a Terraform variable instead of being hardcoded throughout the configuration.

---

### `versions.tf`

This file defines the Terraform and AWS provider requirements for the project.

I also keep `.terraform.lock.hcl` in Git so that Terraform can use consistent provider versions.

---

### `main.tf`

This is where I connect everything together.

Instead of creating the EC2 instance directly here, I:

1. Look up the default VPC.
2. Find the latest Ubuntu AMI.
3. Call my reusable `ec2_web_server` module.
4. Pass the required values into the module.

The flow is basically:

```text
AWS Provider
     |
     +----> Find Default VPC
     |
     +----> Find Ubuntu AMI
                    |
                    v
             Web Server Module
```

---

### `variables.tf`

I created variables so that configuration values do not have to be hardcoded inside the resources.

Some of the values I made configurable are:

```text
AWS Region
EC2 Instance Type
Instance Name
Allowed CIDR
Webpage Title
Webpage Message
```

This makes it easier to reuse the configuration.

---

### `terraform.tfvars.example`

I created an example variable file instead of committing my actual `terraform.tfvars`.

A user can create their local configuration with:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Example values:

```hcl
aws_region      = "us-east-1"
instance_type   = "t3.micro"
instance_name   = "terraform-webserver"
allowed_cidr    = "0.0.0.0/0"

webpage_title = "Terraform Apache Web Server"

webpage_message = "Apache was deployed automatically using a reusable Terraform module."
```

The actual `terraform.tfvars` is ignored by Git.

---

# Reusable EC2 Web Server Module

The main part of this assignment is:

```text
modules/ec2_web_server/
```

Initially, I had only the EC2 resource inside the module.

I later improved the design so that the module owns the complete web-server configuration instead of just wrapping an EC2 instance.

My module now manages:

```text
ec2_web_server
      |
      +---- Security Group
      |
      +---- EC2 Instance
      |
      +---- Apache User Data
      |
      +---- Custom Webpage
      |
      +---- Encrypted EBS
      |
      +---- IMDSv2
      |
      +---- Module Outputs
```

This makes the module much more useful.

For example, I could reuse it later like this:

```text
                  ec2_web_server
                       MODULE
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
      DEV Server      QA Server      PROD Server
```

The module stays the same. I only need to pass different variable values.

---

# Security Group

I create the Security Group inside the reusable module.

For this assignment, the inbound rule is:

```text
Protocol     TCP
Port         80
Source       allowed_cidr
Purpose      Apache HTTP access
```

Outbound traffic is allowed so the EC2 instance can reach package repositories during startup.

For testing, I used:

```text
0.0.0.0/0
```

for HTTP access.

Because this is a variable, I can restrict the CIDR later without modifying the module.

---

# Apache Installation

I did not manually log in to the new EC2 instance and install Apache.

I automated it through EC2 User Data.

The template is:

```text
modules/ec2_web_server/templates/user_data.sh.tftpl
```

When Terraform creates the instance, the startup process does this:

```text
EC2 Starts
    |
    v
User Data Executes
    |
    v
apt-get update
    |
    v
Install Apache2
    |
    v
Generate index.html
    |
    v
Insert Terraform
Webpage Variables
    |
    v
Enable Apache
    |
    v
Start Apache
    |
    v
Website Available
```

I used Terraform's `templatefile()` function so that the webpage content can also come from variables.

That means I don't need to modify the shell script just to change the webpage title or message.

---

# EC2 Security Improvements

I added two additional security settings while improving the module.

## Encrypted EBS

The EC2 root volume is configured as:

```hcl
root_block_device {
  encrypted   = true
  volume_type = "gp3"
}
```

So the root EBS volume is encrypted.

---

## IMDSv2

I also configured the instance to require IMDSv2:

```hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
```

This means requests to the EC2 Instance Metadata Service require a session token.

---

# AWS Authentication

I ran Terraform from an Ubuntu EC2 instance.

Initially, when I checked AWS access using:

```bash
aws sts get-caller-identity
```

AWS returned:

```text
Unable to locate credentials
```

Instead of storing AWS access keys on the server, I attached an IAM role to the EC2 instance.

After attaching the role, I ran the command again and confirmed that the EC2 instance was assuming the IAM role successfully.

The authentication flow was:

```text
Ubuntu EC2
     |
     v
EC2 IAM Role
     |
     v
Temporary AWS Credentials
     |
     v
Terraform AWS Provider
     |
     v
AWS APIs
     |
     v
Create Infrastructure
```

I did not hardcode AWS access keys in the Terraform files.

---

# Running the Project

## 1. Clone the repository

```bash
git clone <repository-url>
cd Terraform-apache-web-server
```

## 2. Create the local tfvars file

```bash
cp terraform.tfvars.example terraform.tfvars
```

## 3. Initialize Terraform

```bash
terraform init
```

## 4. Format the configuration

```bash
terraform fmt -recursive
```

## 5. Validate

```bash
terraform validate
```

I received:

```text
Success! The configuration is valid.
```

## 6. Review the plan

```bash
terraform plan
```

For my upgraded configuration, Terraform showed:

```text
Plan: 2 to add, 0 to change, 0 to destroy.
```

The resources were:

```text
module.web_server.aws_security_group.web

module.web_server.aws_instance.web
```

## 7. Apply

```bash
terraform apply
```

After reviewing the plan, I entered:

```text
yes
```

Terraform then created the infrastructure.

---

# Outputs

I created Terraform outputs so I don't have to manually search the AWS Console for basic information after deployment.

The outputs include:

```text
availability_zone
instance_id
public_dns
public_ip
security_group_id
website_url
```

I can display them using:

```bash
terraform output
```

The output flow is:

```text
EC2 Module
    |
    +---- Instance ID
    +---- Public IP
    +---- Public DNS
    +---- Security Group ID
    +---- Availability Zone
              |
              v
        Root Outputs
              |
              v
       Terraform CLI
```

---

# Testing the Web Server

After deployment, I tested the server using:

```bash
curl http://<PUBLIC_IP>
```

The command returned the HTML generated by the User Data template.

I also tested the public IP through the browser.

Getting the webpage successfully confirmed the complete path:

```text
Browser / curl
      |
      v
Public EC2 IP
      |
      v
Security Group :80
      |
      v
EC2
      |
      v
Apache
      |
      v
index.html
      |
      v
HTTP Response
```

So I knew that the EC2 instance, Security Group, User Data and Apache configuration were all working together.

---

# Terraform State Investigation

Another part of the assignment was understanding Terraform state.

I started with:

```bash
terraform state list
```

While the infrastructure was running, Terraform showed:

```text
module.web_server.aws_instance.web
module.web_server.aws_security_group.web
```

I inspected the EC2 resource using:

```bash
terraform state show module.web_server.aws_instance.web
```

This allowed me to see information such as:

```text
Instance ID
AMI
Instance Type
Availability Zone
Public IP
Private IP
Security Group
Root Volume
Metadata Configuration
```

I inspected the Security Group using:

```bash
terraform state show module.web_server.aws_security_group.web
```

This showed the VPC, inbound rule, outbound rule and Security Group information.

I documented the investigation separately in:

```text
state-investigation.txt
```

---

# Why Terraform State Matters

One useful thing I learned during this assignment was that Terraform state is not just another generated file.

Terraform uses it to understand:

```text
Terraform Code
      |
      v
Terraform State
      |
      v
Actual AWS Resource
```

I saw this directly when I upgraded my original module.

The previous deployment still had an EC2 instance and Security Group in AWS, but the newly cloned project did not have that old state.

When the new configuration tried to create:

```text
terraform-webserver-sg
```

AWS returned:

```text
InvalidGroup.Duplicate
```

because the old Security Group still existed.

I went back to the original Terraform working directory, where the correct state was available, and ran `terraform destroy`.

Terraform then knew exactly which old EC2 instance and Security Group it needed to remove.

After that, the upgraded module deployed successfully.

That was a useful practical example of why Terraform state needs to be managed carefully.

---

# Git and Terraform State

I do not commit Terraform state or downloaded providers to Git.

My `.gitignore` contains:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
crash.log
```

I do commit:

```text
.terraform.lock.hcl
```

because it records the selected provider version and checksums.

The Git flow for this project is:

```text
Terraform Source Code
        |
        v
     git add
        |
        v
    git commit
        |
        v
     GitHub


Local Runtime Files
        |
        +---- .terraform/
        +---- terraform.tfstate
        +---- terraform.tfvars
        |
        X
    NOT COMMITTED
```

---

# Cleanup

The assignment required me to destroy the resources after testing.

I ran:

```bash
terraform destroy
```

and approved the destroy operation.

After Terraform finished, I checked:

```bash
terraform state list
```

and it returned no resources.

This confirmed that Terraform had removed the infrastructure it was managing.

The full lifecycle I followed was:

```text
Write Terraform
      |
      v
terraform init
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
terraform apply
      |
      v
AWS Resources Created
      |
      v
Test Apache Website
      |
      v
Investigate State
      |
      v
terraform destroy
      |
      v
AWS Resources Removed
```

---

# Problems I Faced

This assignment also gave me some useful troubleshooting experience.

## 1. AWS credentials were not available

Initially:

```text
Unable to locate credentials
```

I solved this by attaching an IAM role to the EC2 instance and verifying it with:

```bash
aws sts get-caller-identity
```

## 2. Terraform provider installation failed

My Ubuntu EC2 root filesystem was almost full.

Terraform failed while downloading the AWS provider with:

```text
no space left on device
```

I checked disk usage and found an old `.terraform` directory consuming around 675 MB.

I removed the old provider cache and cleaned the APT cache. After that, I had enough free space and `terraform init` completed successfully.

## 3. Duplicate Security Group

When I deployed the upgraded module, AWS returned:

```text
InvalidGroup.Duplicate
```

The Security Group from my previous deployment was still present.

I used the previous Terraform state to destroy the old deployment and then applied the upgraded configuration again.

The second deployment completed successfully.

---

# What I Learned

This assignment helped me understand Terraform beyond just writing a few `.tf` files.

I worked through the complete lifecycle:

```text
Configuration
    ↓
Variables
    ↓
Modules
    ↓
Provider
    ↓
Plan
    ↓
Apply
    ↓
AWS Resources
    ↓
Outputs
    ↓
State
    ↓
Destroy
```

The biggest things I took away from this exercise were:

- Why Terraform modules are useful.
- How to make a module reusable through variables.
- How Terraform state maps configuration to real AWS resources.
- How EC2 User Data can automate server configuration.
- How Terraform templates can generate dynamic configuration.
- Why state files should not be committed to Git.
- Why IAM roles are better than hardcoding AWS credentials.
- How Terraform handles the full infrastructure lifecycle.
- How to troubleshoot provider, state and AWS resource conflicts.

---

# Final Result

I successfully built a reusable Terraform module that deploys an Apache web server on AWS.

The module manages:

```text
Security Group
      +
EC2 Instance
      +
Apache Installation
      +
Custom Webpage
      +
Encrypted gp3 Storage
      +
IMDSv2
```

The root Terraform configuration provides the environment-specific inputs while the module handles the web-server implementation.

I deployed the infrastructure, verified the Apache webpage over HTTP, inspected the Terraform state, documented the results, and destroyed the AWS resources after testing.

This project gave me hands-on experience with the complete Terraform workflow instead of creating the same infrastructure manually through the AWS Console.
