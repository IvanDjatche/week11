# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

}

# data "aws_vpc" "default" {
#   default = true
# }

# resource "aws_internet_gateway" "efs" {
#   vpc_id = aws_default_vpc.default_vpc.id
#   tags = {
#     Name = "efs-gtw"
#   }

# }

# route table
# resource "aws_route_table" "route1" {
#   vpc_id = aws_default_vpc.default_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.docker.id
#   }
#   tags = {
#     Name = "Docker-route"
#   }
# }

# Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "efs-Web-SG"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

  # ingress {
  #   description = "ingress port "
  #   #from_port   = ingress.value
  #   from_port   = 8000
  #   to_port     = 8100
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]

  # }
  ingress {
    description = "ingress port "
    #from_port   = ingress.value
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "ingress-port "
    #from_port   = ingress.value
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-Web-SG"
  }
}


# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "efs-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.ec2_key.key_name}.pem"
  content         = tls_private_key.ec2_key.private_key_pem
  file_permission = "400"
}

#data for amazon linux

data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

#create ec2 instances 

resource "aws_instance" "efsInstance" {
  count =2 
  ami                    = data.aws_ami.amazon-2.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = aws_key_pair.ec2_key.key_name
  # user_data              = file("setDocker.sh")
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "ec2-test-efs${count.index + 1}"
  }

}
output "web1_ssh-command" {
  value = "ssh -i ${aws_key_pair.ec2_key.key_name}.pem ec2-user@${aws_instance.efsInstance[0].public_dns}"
}
output "web2_ssh-command" {
  value = "ssh -i ${aws_key_pair.ec2_key.key_name}.pem ec2-user@${aws_instance.efsInstance[1].public_dns}"
}


output "web1_public-ip" {
  value = aws_instance.efsInstance.*.public_ip[0]
}
output "web2_public-ip" {
  value = aws_instance.efsInstance.*.public_ip[1]
}