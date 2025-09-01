# main.tf

provider "aws" {
  region = "us-east-1"
}

# -------------------------------
# 1. VPC
# -------------------------------
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "my-vpc" }
}

# -------------------------------
# 2. Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags   = { Name = "my-igw" }
}

# -------------------------------
# 3. Public Subnet
# -------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "public-subnet" }
}

# -------------------------------
# 4. Private Subnet
# -------------------------------
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private-subnet" }
}

# -------------------------------
# 5. Elastic IP for NAT
# -------------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# -------------------------------
# 6. NAT Gateway in Public Subnet
# -------------------------------
resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags          = { Name = "nat-gateway" }
}

# -------------------------------
# 7. Route Tables
# -------------------------------
# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = { Name = "public-rt" }
}

# Associate Public Subnet
resource "aws_route_table_association" "pub_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mynat.id
  }
  tags = { Name = "private-rt" }
}

# Associate Private Subnet
resource "aws_route_table_association" "priv_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# -------------------------------
# 8. Security Groups
# -------------------------------
# Webserver SG
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}

# RDS SG (only allow from webserver)
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "rds-sg"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-sg" }
}

# -------------------------------
# 9. EC2 Instance in Public Subnet
# -------------------------------
resource "aws_instance" "web" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = { Name = "web-server" }
}

# -------------------------------
# 10. RDS Database in Private Subnet
# -------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]
  tags       = { Name = "rds-subnet-group" }
}

resource "aws_db_instance" "myrds" {
  identifier              = "mydb"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Password123!"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = { Name = "my-rds" }
}

# -------------------------------
# 11. Outputs
# -------------------------------
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.myrds.address
}