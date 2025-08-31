provider "aws" {
  region     = "us-east-1"
}


resource "aws_instance" "shankar" {
  ami           = "ami-01816d07b1128cd2d" # us-east-1
  instance_type = "t2.micro"

  tags = {
    Name = "My_First_Instance"
  }

  }

  resource "aws_eip" "lb" {
  instance = aws_instance.shankar.id
  domain   = "vpc"
}