terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

resource "aws_instance" "web_instance" {
  ami                     = "ami-053b0d53c279acc90" # Use the AMI ID for Ubuntu 20.04 in your desired region
  instance_type           = "t3.micro"             # Change this to your desired instance type
  subnet_id               = "subnet-8f6a9ec4" 
  vpc_security_group_ids  = ["sg-042974940cbae1ab6"]
  key_name                = "scm"   # Change this to your SSH key pair name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<html><h1>Hello from your EC2 instance</h1></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "SCM-Web-Svr"
  }
}

output "public_ip" {
  value = aws_instance.web_instance.public_ip
}
