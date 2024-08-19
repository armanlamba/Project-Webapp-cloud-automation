# final-project-cloud-automation
Two-Tier web application automation with Terraform, Ansible and GitHub Actions

#Prerequisites

Before deploying the project, ensure you have the following:

AWS Account: An active AWS account with permissions to create EC2 instances, VPCs, and other resources.

Terraform Installed: Ensure you have Terraform installed locally. You can download it from Terraform’s official site.

Ansible Installed: Ensure you have Ansible installed on your control host.

GitHub Account: A GitHub account with a repository where the Terraform and Ansible configurations are stored.

SSH Key Pair: An SSH key pair for accessing the EC2 instances.

Deployment Instructions

#Step 1: Clone the Repository

: Clone the project repository from GitHub to your local machine.

git clone https://github.com/armanlamba/final-project-cloud-automation.git

cd final-project-cloud-automation

#Step 2 : make infrastrucure

there are 2 ways to run this 

--> though github

git init 

git add .

git commit -m "new update"  

git pull origin main --rebase

git push origin main

Imp:  make sure you have github action pipeline of terraform script setup to run terraform script 

--> Local computer 

alias tf=terraform

tf init

tf plan

tf apply -auto-approve

#Step 3: Configure Web Servers with Ansible

cd ansible

ansible-playbook -i aws_ec2.yaml playbook3.yaml

#Step 4: Automate Deployments with GitHub Actions

The GitHub repository is configured with GitHub Actions to automate Terraform deployments. On every push to the staging branch or a pull request to the prod branch, the following actions will be triggered:

Security Scan: Tools like trivy and tflint will scan the Terraform code.

Terraform Apply: Automatically apply the Terraform configuration to the specified environment.


#Step 5 Bastion Host access to VMs 

make sure your keypair is added to your bastion server from your local environment.

you can use this command to do it 

scp -i keypair1.pem keypair1.pem keypair1.pub ec2-3-82-126-194.compute-1.amazonaws.com:/home/ec2-user  

connect to ssh link of your bastion server

ssh -i "keypair1.pem" ec2-user@ec2-3-82-126-194.compute-1.amazonaws.com

change to your ssh instance accordingly 

once connected 

login to your vm in private server 

Webserver 5

in this case - ssh -i "keypair1.pem" ec2-user@10.1.5.135

exit

#Cleanup Instructions

terraform destroy -auto-approve

