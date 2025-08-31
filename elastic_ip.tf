provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "myec2" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    key_name = "my-key"
}

resource "aws_eip" "my_eip" {
    instance = aws_instance.myec2.id
    vpc      = true
}

output "public_ip" {
    value = aws_eip.my_eip.public_ip
}


#####aws_eip_assocation####
resource "aws_eip" "my_eip" {
    vpc = true
}

resource "aws_eip_assocation" "eip_assoc" {
    instance_id = aws_instance.myec2.id
    allocation_id = aws_eip_.my_eio.id
}