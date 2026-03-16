# Flask + Express Microservices Deployment on AWS using Terraform

## Overview

This project demonstrates how to deploy a microservices-based application using containerization and Infrastructure as Code.

The system consists of two services:

* **Frontend:** Express.js application
* **Backend:** Flask API

Both services are containerized using Docker and deployed on **AWS ECS Fargate** using **Terraform**.
Traffic is routed using an **Application Load Balancer**.

---

## Technologies Used

* Docker
* Terraform
* AWS ECS Fargate
* AWS ECR
* AWS Application Load Balancer
* Flask (Python)
* Express (Node.js)

---

## Architecture

User requests flow through the Application Load Balancer and are routed to appropriate services running on ECS.

```
            Internet
                │
                ▼
      Application Load Balancer
                │
        ┌───────┴────────┐
        │                │
        ▼                ▼
 Express Frontend     Flask Backend
    (Port 3000)         (Port 5000)
        │                │
        └──── ECS Fargate Tasks ────┘
                    │
                    ▼
            Docker Containers
                    │
                    ▼
             Images stored in ECR
```

Routing configuration:

* `/` → Express frontend
* `/api` → Flask backend

---

## Project Structure

```
flask-express-terraform/
│
├── express-app/
│   ├── Dockerfile
│   └── app.js
│
├── flask-app/
│   ├── Dockerfile
│   └── app.py
│
├── terraform/
│   └── main.tf
│
└── README.md
```

---

## Step 1: Build Docker Images

Build backend image:

```bash
docker build -t flask-backend ./flask-app
```

Build frontend image:

```bash
docker build -t express-frontend ./express-app
```

---

## Step 2: Push Images to ECR

Login to ECR:

```bash
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
```

Tag images:

```bash
docker tag flask-backend:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-backend-repo:latest

docker tag express-frontend:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/express-frontend-repo:latest
```

Push images:

```bash
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-backend-repo:latest

docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/express-frontend-repo:latest
```

---

## Step 3: Deploy Infrastructure with Terraform

Initialize Terraform:

```bash
terraform init
```

Deploy infrastructure:

```bash
terraform apply
```

Confirm when prompted:

```
yes
```

Terraform provisions the following AWS resources:

* VPC
* Public Subnets
* Internet Gateway
* Security Groups
* ECS Cluster
* ECS Task Definitions
* ECS Services
* ECR Repositories
* Application Load Balancer

---

## Step 4: Access the Application

After deployment, Terraform outputs the Load Balancer DNS.

Example:

```
http://flask-express-alb-xxxx.us-east-1.elb.amazonaws.com
```

Test the services:

Frontend:

```
http://ALB-DNS
```

Backend API:

```
http://ALB-DNS/api
```

Expected response:

```json
{
  "message": "Hello from Flask backend"
}
```

---

## Key Learning Outcomes

* Containerizing applications using Docker
* Managing infrastructure using Terraform
* Deploying containers using ECS Fargate
* Using ECR as a container registry
* Configuring Application Load Balancer routing
* Implementing microservice architecture on AWS

---

## Cleanup

To remove all resources created by Terraform:

```bash
terraform destroy
```

This will delete all AWS infrastructure created during deployment.

---

## Author

Assignment submission for Docker, Terraform, and AWS ECS deployment.
