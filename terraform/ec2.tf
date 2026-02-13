#Blue Instance
resource "aws_instance" "blue" {
  ami                    = "ami-0b6c6ebed2801a5cb"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "ubuntu-ki-key"

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y

              systemctl start docker
              systemctl enable docker

              docker pull guriwaraich/flask-crud:v1

              docker run -d -p 5000:5000 \
                -e DB_HOST=${aws_db_instance.postgres.address} \
                -e DB_NAME=postgres \
                -e DB_USER=postgres \
                -e DB_PASSWORD=postgres123 \
                --restart always \
                guriwaraich/flask-crud:v1
              EOF

  tags = {
    Name = "blue-instance"
  }
}

#Green Instance
resource "aws_instance" "green" {
  ami                    = "ami-0b6c6ebed2801a5cb"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public2.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "ubuntu-ki-key"

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y

              systemctl start docker
              systemctl enable docker

              docker pull guriwaraich/flask-crud:v1

              docker run -d -p 5000:5000 \
                -e DB_HOST=${aws_db_instance.postgres.address} \
                -e DB_NAME=postgres \
                -e DB_USER=postgres \
                -e DB_PASSWORD=postgres123 \
                --restart always \
                guriwaraich/flask-crud:v1
              EOF

  tags = {
    Name = "green-instance"
  }
}
