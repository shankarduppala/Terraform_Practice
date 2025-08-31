provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "mykey" {
    key_name = "mykey"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ec2_sg" {
    name = "ec2-security-group"
    description = "Allow SSH and HTTP"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "myec2" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    key_name = aws_key_pair.mykey.key_name
    security_groups = [aws_security_group.ec2_sg.name]

    tags = {
        Name = "MyFirstInstance"
    }
}

output "ec2_public_ip" {
    value = aws_instance.myec2.public_ip
}
