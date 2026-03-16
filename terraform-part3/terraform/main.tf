############################
# VPC
############################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

############################
# Subnets
############################

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

############################
# Internet Gateway
############################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

############################
# Route Table
############################

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

############################
# Security Groups
############################

resource "aws_security_group" "alb_sg" {

  name = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
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

resource "aws_security_group" "ecs_sg" {

  name = "ecs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

############################
# ECR
############################

resource "aws_ecr_repository" "flask_repo" {
  name = "flask-backend-repo"
}

resource "aws_ecr_repository" "express_repo" {
  name = "express-frontend-repo"
}

############################
# ECS Cluster
############################

resource "aws_ecs_cluster" "main" {
  name = "flask-express-cluster"
}

############################
# IAM Role
############################

resource "aws_iam_role" "ecs_task_execution_role" {

  name = "ecsTaskExecutionRole1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {

  role = aws_iam_role.ecs_task_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}

############################
# Load Balancer
############################

resource "aws_lb" "alb" {

  name = "flask-express-alb"

  load_balancer_type = "application"

  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

  security_groups = [
    aws_security_group.alb_sg.id
  ]

}

############################
# Target Groups
############################

resource "aws_lb_target_group" "express_tg" {

  name = "express-tg"

  port = 3000
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  target_type = "ip"

}

resource "aws_lb_target_group" "flask_tg" {

  name     = "flask-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "ip"

  health_check {

    path = "/api"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2

  }

}

############################
# Listener
############################

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn

  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.express_tg.arn
  }

}

############################
# Route /api → Flask
############################

resource "aws_lb_listener_rule" "flask_rule" {

  listener_arn = aws_lb_listener.http.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api*"]
    }
  }

}

############################
# Task Definitions
############################

resource "aws_ecs_task_definition" "flask_task" {

  family = "flask-task"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu = "512"
  memory = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name = "flask"
      image = "${aws_ecr_repository.flask_repo.repository_url}:latest"

      portMappings = [
        {
          containerPort = 5000
        }
      ]
    }
  ])

}

resource "aws_ecs_task_definition" "express_task" {

  family = "express-task"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu = "512"
  memory = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name = "express"
      image = "${aws_ecr_repository.express_repo.repository_url}:latest"

      portMappings = [
        {
          containerPort = 3000
        }
      ]
    }
  ])

}
############################
# ECS Services
############################

resource "aws_ecs_service" "express_service" {

  name = "express-service"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.express_task.arn

  desired_count = 1

  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.express_tg.arn
    container_name = "express"
    container_port = 3000
  }

  network_configuration {

    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id
    ]

    security_groups = [
      aws_security_group.ecs_sg.id
    ]

    assign_public_ip = true
  }

}

resource "aws_ecs_service" "flask_service" {

  name = "flask-service"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.flask_task.arn

  desired_count = 1

  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_tg.arn
    container_name = "flask"
    container_port = 5000
  }

  network_configuration {

    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id
    ]

    security_groups = [
      aws_security_group.ecs_sg.id
    ]

    assign_public_ip = true
  }

}
