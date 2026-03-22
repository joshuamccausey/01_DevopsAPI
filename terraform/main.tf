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


# Create an EC2 key pair for SSH access
resource "aws_key_pair" "deployer" {
  key_name   = "developer_key"
  public_key = file("~/.ssh/aws_ec2_key.pub")
}

# Networking resources

resource "aws_security_group" "app_server_sg" {
  name        = "app_server_sg"
  description = "Allow HTTP traffic to app server"
  vpc_id      = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}


# EC2 instance for the application server

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t4g.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  tags = {
    Name = "01_devopsapi_app_server"
  }

  user_data = <<-EOF
  #!/bin/bash
  apt-get update
  apt-get install -y docker.io
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ubuntu
  apt-get install -y git
EOF

}

# Public IP output for GitHub Action to SSH into EC2 instance and deploy docker container
output "public_ip" {
  value = aws_instance.app_server.public_ip
}
