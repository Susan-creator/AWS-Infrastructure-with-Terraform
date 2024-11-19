# AWS Infrastructure Setup with Terraform

This Terraform project sets up an AWS infrastructure comprising:
- A Virtual Private Cloud (VPC) with subnets, route tables, and an internet gateway.
- Security groups to control inbound and outbound traffic.
- An Application Load Balancer (ALB) with a listener and target group.
- Two EC2 instances with IAM roles for secure access to an S3 bucket.
- An S3 bucket for storing and accessing data.

## Features
- **Highly Available Infrastructure**: Deploys resources across two availability zones.
- **IAM Role Integration**: Provides EC2 instances with secure, limited access to the S3 bucket.
- **Load Balancing**: Distributes incoming traffic to two EC2 instances.
- **Infrastructure as Code**: Reproducible and version-controlled setup using Terraform.

---

## Prerequisites
1. **Terraform**: Installed on your local machine. [Install Terraform](https://www.terraform.io/downloads).
2. **AWS CLI**: Installed and configured with appropriate credentials. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
3. **Key Pair**: An existing AWS EC2 key pair for SSH access to the instances.
4. **AMI**: A valid Amazon Machine Image (AMI) ID for EC2 instances.
5. **Terraform Variables**:
    - `cidr_block`: CIDR block for the VPC (e.g., `10.0.0.0/16`).
    - `instance_type`: Instance type for EC2 (e.g., `t2.micro`).
    - `key_name`: Name of the EC2 key pair.

---

## Project Structure

# Primary Terraform configuration 
main.tf 
# Variables used in the configuration 
variables.tf 
# Outputs (e.g., ALB DNS name) 
outputs.tf 
# User data script for webserver1
userdata.sh 
# User data script for webserver2 
userdata1.sh 
 # Documentation for the project
 README.md 




---

## Configuration Steps
**Clone the Repository**:
   ```bash
   git clone <https://github.com/Susan-creator/AWS-Infrastructure-with-Terraform.git>
   cd <repository-directory>


Set Variables: Update the variables.tf file or provide variables through a .tfvars file or CLI.

Prepare User Data: Update userdata.sh and userdata1.sh to include the startup scripts for your EC2 instances.

Initialize Terraform: Run the following command to initialize Terraform providers:

bash
terraform init
Plan the Infrastructure: Preview the changes Terraform will make:

bash
terraform plan
Apply the Configuration: Deploy the infrastructure:

bash
terraform apply
Access the Load Balancer: After deployment, Terraform outputs the DNS name of the ALB. Use it to access your application.

Outputs
Load Balancer DNS: The DNS name for the ALB to access the application.


Clean Up
To destroy all resources created by this project:

bash
terraform destroy



Components Overview
1. Networking
VPC: Custom VPC with two public subnets.
Route Table: Allows internet access via an Internet Gateway.
2. Security
Security Groups:
Inbound rules for HTTP (port 80) and SSH (port 22).
Outbound rule to allow all traffic.
3. Compute
EC2 Instances:
Two instances deployed in separate subnets.
IAM instance profile for secure access to S3.
4. Storage
S3 Bucket:
A bucket named test-s3bucket-sue8.
Policy allows EC2 instances to access objects in the bucket.
5. Load Balancer
Application Load Balancer (ALB):
Distributes traffic to the EC2 instances.
Integrated with a target group and listener.
Notes
Ensure the aws_region is set correctly in your environment or provider configuration.
Replace placeholders like <repository-url> and variables with your specific values.
Update the AMI IDs to match your AWS region and requirements.
Authors
This project was created by [ Susan Owoicho ]. Feel free to contribute or raise issues.

