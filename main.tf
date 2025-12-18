terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "free-tier-instance-sg"
  description = "Security group for free tier EC2 instance"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "FreeTierInstanceSG"
  }
}

# EC2 Instance
resource "aws_instance" "free_tier_instance" {
  ami           = "ami-00ca570c1b6d79f36"
  instance_type = "t2.micro"  # Free tier eligible

  # Attach security group
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  # Enable detailed monitoring (free tier: 10 custom metrics)
  monitoring = false

  # Root volume configuration (free tier: 30 GB)
  root_block_device {
    volume_size           = 20  # GB
    volume_type           = "gp3"  # General Purpose SSD
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "FreeTierInstanceVolume"
    }
  }

  # User data script to update packages on launch
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  # Enable termination protection
  disable_api_termination = false

  # Tags
  tags = {
    Name        = "FreeTierInstance"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }

  # Optional: Uncomment if you have a key pair for SSH access
  # key_name = "your-key-pair-name"
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.free_tier_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.free_tier_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.free_tier_instance.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.instance_sg.id
}
