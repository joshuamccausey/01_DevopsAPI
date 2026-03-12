provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-arm64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name = "developer_key"
  public_key = file("~/.ssh/aws_ec2_key.pub")
}

resource "aws_security_group" "app_server_sg" {
  name        = "app_server_sg"
  description = "Allow HTTP traffic to app server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["66.187.96.118/32"]
}

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["66.187.96.118/32"]
  }

}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.micro"
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.app_server_sg.name] 

  tags = {
    Name = "01_devopsapi_app_server"
  }
}
