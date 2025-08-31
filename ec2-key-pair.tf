provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "mykey" {
    key_name   = "MyKey"
    public_key = file("~/.ssh/id_rsa.pub")
}