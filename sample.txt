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

resource "aws_instance" "free_tier_instance" {
  ami           = "ami-00ca570c1b6d79f36"
  instance_type = "t2.micro"

  tags = {
    Name = "FreeTierInstance"
  }
}

output "instance_id" {
  value = aws_instance.free_tier_instance.id
}

output "instance_public_ip" {
  value = aws_instance.free_tier_instance.public_ip
}
