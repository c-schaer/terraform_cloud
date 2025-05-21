#----------------------------------------------------------
#  Terraform  
#
# Outputs
#
#  
#----------------------------------------------------------

variable "accountid" {}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.accountid}:role/automation" # Role in dev account
  }
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_instance" "my_server_web" {
  ami                    = "ami-0953476d60561c955"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  tags                   = { Name = "Server-Web" }

  depends_on = [
    aws_instance.my_server_db,
    aws_instance.my_server_app
  ]
}

resource "aws_instance" "my_server_app" {
  ami                    = "ami-0953476d60561c955"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  tags                   = { Name = "Server-App" }

  depends_on = [aws_instance.my_server_db]
}

resource "aws_instance" "my_server_db" {
  ami                    = "ami-0953476d60561c955"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  tags                   = { Name = "Server-DB" }
}


resource "aws_security_group" "general" {
  name   = "My Security Group"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443", "22", "3389"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My SecurityGroup"
  }
}

#-----------------------------
output "my_securitygroup_id" {
  description = "Security Group ID for my Servers"
  value       = aws_security_group.general.id
}


output "my_securitygroup_all_detais" {
  description = "All the details of my Security Group for my Servers"
  value       = aws_security_group.general
}


output "web_private_ip" {
  value = aws_instance.my_server_web.private_ip
}

output "app_private_ip" {
  value = aws_instance.my_server_app.private_ip
}

output "db_private_ip" {
  value = aws_instance.my_server_db.private_ip
}

output "instances_ids" {
  value = [
    aws_instance.my_server_web.id,
    aws_instance.my_server_app.id,
    aws_instance.my_server_db.id
  ]
}
