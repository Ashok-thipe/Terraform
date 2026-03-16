# DevOps Microservices Assignment (Docker • ECS • Terraform • AWS)

## Overview

This project demonstrates deploying a simple microservices application using modern DevOps tools and AWS services.
The application consists of two services:

* **Frontend:** Express.js (Node.js)
* **Backend:** Flask (Python)

Both services are containerized using **Docker** and deployed in multiple ways across three assignment parts.

---

## Assignment Parts

### Part 1 — Docker Deployment

* Built Docker images for Flask backend and Express frontend.
* Ran containers locally on a single EC2 instance.
* Verified communication between frontend and backend services.

**Technologies:** Docker, Flask, Express.js

---

### Part 2 — AWS ECR & ECS Deployment

* Pushed Docker images to **Amazon ECR**.
* Deployed containers using **AWS ECS Fargate**.
* Created ECS services for both frontend and backend.

**Technologies:** AWS ECS, AWS ECR, Docker

---

### Part 3 — Terraform Infrastructure Deployment

* Used **Terraform** to provision AWS infrastructure.
* Created:

  * VPC
  * Subnets
  * Security Groups
  * ECS Cluster
  * ECS Services
  * Application Load Balancer
* Configured routing:

  * `/` → Express frontend
  * `/api` → Flask backend

**Technologies:** Terraform, AWS ECS, AWS ALB

---

## Architecture

```
Internet
   │
   ▼
Application Load Balancer
   │
 ┌─┴───────────┐
 │             │
 ▼             ▼
Express      Flask
Frontend     Backend
(3000)       (5000)
 │             │
 └── ECS Fargate Containers
          │
          ▼
      Docker Images
          │
          ▼
        AWS ECR
```

---

## Project Structure

# 📁 Project Structure

```
terraform
│
├── terraform-part1/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── userdata.sh
│
├── terraform-part2/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── express_userdata.sh
│   └── flask_userdata.sh
│
├── terraform-part3/
│   │
│   ├── express-app/
│   │   ├── Dockerfile
│   │   └── app.js
│   │
│   ├── flask-app/
│   │   ├── Dockerfile
│   │   └── app.py
│   │
│   └── terraform/
│       └── main.tf
│
├── .gitignore
└── README.md
```

## Folder Description

### terraform-part1

Contains Terraform configuration for the initial infrastructure setup and EC2 provisioning.

Files include:

* `provider.tf` – AWS provider configuration
* `variables.tf` – input variables
* `main.tf` – infrastructure resources
* `outputs.tf` – output values
* `userdata.sh` – EC2 initialization script

---

### terraform-part2

Extends infrastructure deployment with separate EC2 instances for frontend and backend.

Files include:

* Terraform configuration files
* User data scripts for:

  * Express service
  * Flask service

---

### terraform-part3

Implements containerized microservices deployment using Docker and AWS ECS.

Includes:

* Express frontend application
* Flask backend application
* Terraform configuration for ECS, ECR, and Load Balancer

---

## How to Run (Terraform Deployment)

Initialize Terraform:

```
terraform init
```

Deploy infrastructure:

```
terraform apply
```

Destroy infrastructure:

```
terraform destroy
```

---

## Key Learning Outcomes

* Containerizing applications with Docker
* Using AWS ECR as a container registry
* Deploying containers using ECS Fargate
* Managing infrastructure using Terraform
* Implementing microservices architecture on AWS

---

