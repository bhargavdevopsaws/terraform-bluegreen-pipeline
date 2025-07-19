Jenkins + Terraform Blue/Green Deployment Pipeline on AWS

✨ Overview

This document summarizes the complete implementation of a Blue/Green Deployment strategy using Jenkins and Terraform on AWS. It includes the architecture, execution steps, and key configuration files used throughout the process.

🔍 Task Description

Automate a zero-downtime Blue/Green deployment on AWS using Jenkins and Terraform. The pipeline should:

Deploy "blue" and "green" environments separately

Use Terraform for infrastructure provisioning

Use Jenkins to automate Terraform commands

Shift traffic using Application Load Balancer (ALB)

✅ Prerequisites

AWS Resources:

Valid AWS account (unblocked and verified)

IAM User or Role with permissions: EC2, ALB, Auto Scaling, IAM, S3 (optional)

Local/Server Tools:

Ubuntu 22.04 EC2 (for Jenkins)

Jenkins installed and running

Terraform installed (v1.5+)

Git installed

Java 11+ for Jenkins

Project Structure (Terraform Repo)

Folder Structure:  
terraform-bluegreen-pipeline/
├── Jenkinsfile
├── blue/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── backend.tf
│   └── outputs.tf
├── green/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── backend.tf
│   └── outputs.tf

Push code to GitHub

git add .
git commit -m "Blue deployment setup"
git push origin main


🛠️ Tools Used

Terraform - Infrastructure as Code (IaaC)

Jenkins - CI/CD tool for automation

GitHub - Version control and Jenkins integration

AWS - Cloud hosting for deployments

🔗 Jenkins Setup

Install Java

sudo apt update
sudo apt install openjdk-11-jdk -y

Install Jenkins

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y

Start Jenkins
> sudo systemctl start jenkins
> sudo systemctl enable jenkins

Unlock Jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

🚀 Pipeline Execution Steps

🔵 Blue Deployment

Update terraform.tfvars:

environment = "blue"



Run Jenkins job

It triggers Terraform: init, plan, apply

Deploys EC2 + ALB for "blue"

🔶 Green Deployment

Update terraform.tfvars:

environment = "green"

Replace EC2 with Launch Template + ASG in main.tf

Commit and push changes:

git add .
git commit -m "Green deployment setup"
git push origin main

Jenkins deploys green infra using same pipeline.
Jenkinsfile

🔹 Summary

We built a full CI/CD pipeline for Terraform-based Blue/Green deployment

Jenkins automates the infrastructure lifecycle

ALB listener rules control traffic between environments

Minimal downtime and safer deployments

