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