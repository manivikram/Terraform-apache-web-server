data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "web_server" {
  source = "./modules/ec2_web_server"

  ami_id          = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  instance_name   = var.instance_name
  vpc_id          = data.aws_vpc.default.id
  allowed_cidr    = var.allowed_cidr
  webpage_title   = var.webpage_title
  webpage_message = var.webpage_message
}
