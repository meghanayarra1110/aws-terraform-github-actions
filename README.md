# AWS Infrastructure Automation with Terraform & GitHub Actions

## Overview

This project demonstrates Infrastructure as Code (IaC) and automated AWS infrastructure deployment using Terraform and GitHub Actions.

Terraform provisions the AWS infrastructure, while GitHub Actions automatically validates, plans, and applies infrastructure changes.

AWS IAM OIDC authentication is used so GitHub Actions can access AWS without storing long-lived AWS access keys.

Terraform state is stored remotely in Amazon S3 with state locking enabled.

## Architecture

```text
GitHub
   |
   v
GitHub Actions
   |
   v
AWS IAM OIDC
   |
   v
Terraform
   |
   +--------------------+
   |                    |
   v                    v
Amazon S3           AWS VPC
Remote State            |
                        v
                  Public Subnet
                        |
                  +-----+-----+
                  |           |
                  v           v
             Route Table   Security Group
                                |
                                v
                               EC2
                                |
                              Docker
                                |
                              Nginx
```

## Technologies Used

- Terraform
- AWS
- GitHub Actions
- AWS IAM OIDC
- Amazon S3
- Amazon VPC
- Amazon EC2
- Docker
- Linux
- Nginx
- Git & GitHub

## AWS Infrastructure

Terraform provisions:

- Custom VPC
- Public subnet
- Internet Gateway
- Public route table
- Route table association
- Security group
- EC2 instance

## Application Deployment

The EC2 instance uses Terraform `user_data` to:

1. Update the operating system
2. Install Docker
3. Start the Docker service
4. Pull the Nginx Alpine image
5. Run the Nginx container
6. Expose the application on port 80

## Terraform Remote State

Terraform state is stored remotely in Amazon S3.

The backend configuration uses:

- S3 bucket for remote state
- `terraform.tfstate` as the state file
- S3 lockfile-based state locking
- S3 bucket versioning

This allows GitHub Actions and local Terraform operations to use the same infrastructure state.

## GitHub Actions CI/CD

GitHub Actions automatically runs:

```text
terraform init
       ↓
terraform fmt -check
       ↓
terraform validate
       ↓
terraform plan
       ↓
terraform apply
```

Terraform Apply runs automatically when changes are pushed to the `main` branch.

## AWS OIDC Authentication

GitHub Actions authenticates with AWS using an IAM OIDC trust relationship.

No long-lived AWS access keys are stored as GitHub repository secrets.

The workflow assumes the IAM role:

```text
GitHubActionsTerraformRole
```

## Project Structure

```text
aws-terraform-github-actions/
│
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── main.tf
├── outputs.tf
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

## Deployment Result

The infrastructure was successfully provisioned on AWS using Terraform.

GitHub Actions successfully authenticated to AWS using OIDC and executed Terraform initialization, validation, planning, and application.

The Dockerized Nginx application is deployed on the Terraform-managed EC2 instance.

## Key DevOps Concepts Demonstrated

- Infrastructure as Code
- Terraform state management
- Remote state
- State locking
- AWS networking
- EC2 provisioning
- Docker containerization
- CI/CD automation
- GitHub Actions
- AWS IAM
- OIDC authentication
- Linux automation

## Author

Meghana Yarra

GitHub: github.com/meghanayarra1110
