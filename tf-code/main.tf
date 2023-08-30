terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

provider "aws" {
  #region = "us-east-1"
}

resource "aws_instance" "example_instance" {
  ami           = "ami-053b0d53c279acc90" 
  instance_type = "t3.micro" 

  subnet_id = "subnet-8f6a9ec4" 

  # Security group IDs for your instance
  vpc_security_group_ids = ["sg-042974940cbae1ab6"]

  key_name = "scm" # Replace with your key pair name

  user_data = <<EOF

#!/bin/bash
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
sudo ufw allow 'Apache'
sudo systemctl status apache2

EOF

  tags = {
    Name = "SCM-Web-Svr"
  }
}
