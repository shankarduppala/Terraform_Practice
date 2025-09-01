resource "aws_internet_getway" "mygw" {
    vpc_id = aws_vpc.myvpc.vpc_id
    tags = { NAme = "my-igw"}
}