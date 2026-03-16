resource "aws_security_group" "app_sg" {

  name = "flask-express-sg"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port = 3000
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
resource "aws_instance" "app_server" {

  ami           = "ami-0030e4319cbf4dbf2"
  instance_type = "t2.micro"

  key_name = var.key_name

  security_groups = [aws_security_group.app_sg.name]

  user_data = file("userdata.sh")

  tags = {
    Name = "flask-express-server"
  }
}
