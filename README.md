# terraform_vpc_module_automated_wp_deployment

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

## Description

Terraform is an open-source infrastructure-as-code(IAC) software for building, changing, and versioning infrastructure safely and efficiently.
Here is a simple demonstration of using Terraform to build an AWS infra to launch a wordpress website.

## Features


- All resources are created using terraform
- Bastion, frontend, and backend instances are used to enhance security.
- We can easily customize the code for various environments.
- Prefix list restricts SSH access to the authorized IPs only.
- Subnet CIDR blocks are created using cidrsubnet function
- Elastic IP and NAT gateway are created based on the requirement.
- DNS zones and records are created using Terraform.


## Prerequisites for this project

- IAM user with programmatic access and permission to create the required resources.
- Knowledge of the working principles of AWS services like VPC, EC2, and Route53.


| Variable | Description |
| ------ | ------ |
| region  | your aws region  |
| access_key | your access key |
| secret_key  | your secret key |
| project  | your project name  |
| environment  | your project environment |
| instance_ami  | preffered Amazon Machine Image |
| instance_type  | preffered aws instance type |
| vpc_cidr  | CIDR block for the VPC |
| db_name  | preffered database name |
| db_username  | database username for the wordpress website |
| db_password  | password for the database user |
| mysqlrootpwd  | mysql root user password |
|  private_zone | private hosted DNS zone  |
|  wp_domain | your FQDN  |
| public_ips  | IPs that can SSH to the bastion server  |
|  public_ssh_to_frontend | condition check; if  this is set to true, ssh access to the frontend webserver will be open to all |
| public_ssh_to_backend  | condition check; if  this is set to true, ssh access to the backend databse server will be open to all |
|  frontend_ports |  http and https ports for frontend server |
| backend_port  | mysql port for database server  | 
| bastion_port  | ssh port for bastion server  |

To download project files to your local system, you need to execute
```sh
git clone https://github.com/sreenidhiramachandran/terraform_vpc_module_automated_wp_deployment.git

```

To run this terraform code; you need to execute

```sh
$ terraform init
$ terraform plan
$ terraform apply
```
