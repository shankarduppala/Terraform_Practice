#elastic ip for NAT

resource "aws_eip" "nat_eip" {
    domain = "vpc"
}

# NAT gateway in public subnets

resource "aws_nat_gatway" "mynat" {
    allocation_id = aws_eip.nat_eip.id 
    subnet_id = aws_subnet.public_subnet.id
    tags = { Name = "nat-gateway" }
}


