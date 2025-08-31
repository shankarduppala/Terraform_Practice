provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "mykey" {
    key_name   = "MyKey"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "myec2" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    key_name = aws_key_pair.mykey.key_name
}