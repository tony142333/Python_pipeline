# --- 0. SETUP PROVIDERS ---
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "github" {
  token = var.github_token # Reads from terraform.tfvars
}

# --- VARIABLES ---
variable "github_token" {
  sensitive = true
}
variable "repo_name" {
  type = string
}

# --- 1. FIREWALL (Security Group) ---
resource "aws_security_group" "web_sg" {
  name        = "pipeline-sg-8080-auto" # Renamed slightly to avoid conflicts
  description = "Allow SSH and Port 8080"

  # SSH (Port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App (Port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- 2. THE SERVER (EC2) ---
resource "aws_instance" "app_server" {
  # YOUR FIXED AMI
  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"

  # YOUR KEY
  key_name      = "tarun"

  security_groups = [aws_security_group.web_sg.name]

  # Startup Script
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Pipeline-Auto-Server"
  }
}

# --- 3. THE MAGIC: AUTO-UPDATE GITHUB ---
resource "github_actions_secret" "server_ip_secret" {
  repository      = var.repo_name
  secret_name     = "SSH_HOST"
  plaintext_value = aws_instance.app_server.public_ip
}

# --- OUTPUT ---
output "server_ip" {
  value = aws_instance.app_server.public_ip
}