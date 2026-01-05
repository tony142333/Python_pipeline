provider "aws" {
  region = "us-east-1"
}

# --- 1. FIREWALL (Security Group) ---
resource "aws_security_group" "web_sg" {
  name        = "pipeline-sg-8080-simple"
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
  # Ubuntu 24.04 LTS (us-east-1) - Fixed ID
  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"

  # 👇 CHANGE THIS to your actual AWS Key Pair name
  key_name      = "tarun"

  security_groups = [aws_security_group.web_sg.name]

  # Startup Script: Install Docker
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Pipeline-Demo-Server"
  }
}

output "server_ip" {
  value = aws_instance.app_server.public_ip
}