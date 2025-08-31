resource "aws_security_group" "ec2_sg" {
    name = "ec2_security_group"
    description = "allow SSH and HTTP"

    ingress {
        from_port  = 22
        to_port   = 22
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
    security_groups = [aws_security_group.ec2_sg.name]
}