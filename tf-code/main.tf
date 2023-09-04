terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

resource "aws_instance" "web_instance" {
  ami                     = "ami-053b0d53c279acc90"
  instance_type           = "t3.micro"
  subnet_id               = "subnet-8f6a9ec4" 
  vpc_security_group_ids  = ["sg-042974940cbae1ab6"]
  key_name                = "scm"

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<html><h1>Hello from your EC2 instance</h1></html>" > /var/www/html/index.html
              apt install -y awscli
              EOF

  tags = {
    Name = "SCM-Web-Svr"
  }

  iam_instance_profile = "scm_ec2_profile"
}

resource "aws_iam_instance_profile" "scm_ec2_profile" {
  name = "scm_ec2_profile"
  role = aws_iam_role.scm_role.name
}

resource "aws_iam_role" "scm_role" {
  name = "scm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "s3_full_access_policy"
  description = "Policy for full access to Amazon S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
  role       = aws_iam_role.scm_role.name
}

output "public_ip" {
  value = aws_instance.web_instance.public_ip
}
