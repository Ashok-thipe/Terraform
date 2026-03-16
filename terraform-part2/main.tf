resource "aws_vpc" "main_vpc" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "flask-express-vpc"
  }

}
resource "aws_subnet" "public_subnet" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  availability_zone = "us-east-1a"

}
resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main_vpc.id

}
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main_vpc.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id

  }

}
resource "aws_route_table_association" "rt_assoc" {

  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

}
resource "aws_security_group" "flask_sg" {

  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}
resource "aws_security_group" "express_sg" {

  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}
resource "aws_instance" "flask_server" {

  ami           = "ami-0030e4319cbf4dbf2"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  key_name = var.key_name

  user_data = file("flask_userdata.sh")

  tags = {
    Name = "flask-backend"
  }

}
resource "aws_instance" "express_server" {

  ami           = "ami-0030e4319cbf4dbf2"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.express_sg.id]

  key_name = var.key_name

  user_data = file("express_userdata.sh")

  tags = {
    Name = "express-frontend"
  }

}
