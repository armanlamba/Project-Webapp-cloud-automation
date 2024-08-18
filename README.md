# final-project-cloud-automation
Two-Tier web application automation with Terraform, Ansible and GitHub Actions

Prerequisites
Before deploying the project, ensure you have the following:

AWS Account: An active AWS account with permissions to create EC2 instances, VPCs, and other resources.
Terraform Installed: Ensure you have Terraform installed locally. You can download it from Terraform’s official site.
Ansible Installed: Ensure you have Ansible installed on your control host.
GitHub Account: A GitHub account with a repository where the Terraform and Ansible configurations are stored.
SSH Key Pair: An SSH key pair for accessing the EC2 instances.

Deployment Instructions

Step 1: Clone the Repository
: Clone the project repository from GitHub to your local machine.

git clone https://github.com/armanlamba/final-project-cloud-automation.git

cd final-project-cloud-automation

Step 2: Initialize Terraform

alias tf=terraform

tf validate

tf plan

tf apply -auto-approve

Step 3: Configure Web Servers with Ansible

ansible-playbook -i aws_ec2.yaml playbook3.yaml

Step 4: Automate Deployments with GitHub Actions

The GitHub repository is configured with GitHub Actions to automate Terraform deployments. On every push to the staging branch or a pull request to the prod branch, the following actions will be triggered:

Security Scan: Tools like trivy and tflint will scan the Terraform code.

Terraform Apply: Automatically apply the Terraform configuration to the specified environment.

Cleanup Instructions

terraform destroy
