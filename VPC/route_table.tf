#Public route table

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gatway.myigw.id
    }
    tags = { Name = "public_rt"}
}

# Associate public subnet

resource "aws_route_table_association" "pub_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

#private route table

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gatway.mynat.id
    }
    tags = { Name = "private_rt"}
}

# Associate private subnet

resource "aws_route_table_association" "priv_assoc" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}
