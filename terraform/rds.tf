#Create DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "blue-green-db-subnet-group"

  subnet_ids = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

  tags = {
    Name = "blue-green-db-subnet-group"
  }
}

#Create DB Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow PostgreSQL access from EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create PostgreSQL RDS
resource "aws_db_instance" "postgres" {
  identifier              = "blue-green-postgres"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "postgres"
  username                = "postgres"
  password                = "postgres123"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
  multi_az                = false

  tags = {
    Name = "blue-green-postgres"
  }
}
