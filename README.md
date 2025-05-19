# Focalboard AWS Terraform Deployment

This project automates the deployment of Focalboard on AWS using Docker and Terraform. It provisions a VPC, public subnets, an EC2 instance running Focalboard via Docker, and an Application Load Balancer (ALB) to expose the service.

---

## 🚀 Features

- Infrastructure as Code using Terraform
- EC2 instance with Docker and Focalboard
- Application Load Balancer for public access
- Customizable via variables

---

## 📦 Prerequisites

- AWS account with appropriate IAM permissions
- Terraform installed
- AWS CLI configured (`aws configure`)
- Git installed

---

## 📁 Project Structure