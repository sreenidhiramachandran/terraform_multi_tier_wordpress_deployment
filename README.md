# terraform_vpc_module_automated_wp_deployment

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

## Description
Terraform is an open-source infrastructure as code (IaC) tool that allows us to define and manage cloud infrastructure resources using a high-level configuration language. It provides a simple, declarative syntax for defining infrastructure resources, such as virtual machines, storage buckets, network interfaces, and load balancers, across multiple cloud providers, including Amazon Web Services (AWS), Microsoft Azure, and Google Cloud Platform (GCP).

We can define the infrastructure in a single file or in a modular fashion, using reusable components called modules.Here I am using a VPC module in the project.

Terraform is designed to be cloud-agnostic, meaning that you can use the same configuration language to define infrastructure resources across different cloud providers. It also supports a wide range of cloud resources and services, including compute, networking, storage, databases, and security.

Terraform works by creating an execution plan based on the configuration, which describes the changes that will be made to the infrastructure. It then applies the changes in a safe and predictable manner, ensuring that the infrastructure is always in the desired state.

This is a brief demonstration on how to use Terraform to construct an AWS infrastructure that will enable the deployment of a WordPress website.


<a href="https://ibb.co/zQj6T28"><img src="https://i.ibb.co/34GR9Ff/aanew-drawio.png" alt="aanew-drawio" border="0"></a>



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

## Variables Used

| Variable | Description |
| ------ | ------ |
| region  | your aws region  |
| access_key | your access key |
| secret_key  | your secret key |
| project  | your project name  |
| environment  | your project environment |
| instance_ami  | preferred Amazon Machine Image |
| instance_type  | preferred aws instance type |
| vpc_cidr  | CIDR block for the VPC |
| db_name  | preferred database name |
| db_username  | database username for the wordpress website |
| db_password  | password for the database user |
| mysqlrootpwd  | mysql root user password |
|  private_zone | private hosted DNS zone  |
|  wp_domain | your FQDN  |
| public_ips  | IPs that can SSH to the bastion server  |
|  public_ssh_to_frontend | condition check; if  this is set to true, ssh access to the frontend webserver will be open to all |
| public_ssh_to_backend  | condition check; if  this is set to true, ssh access to the backend database server will be open to all |
|  frontend_ports |  http and https ports for the frontend server |
| backend_port  | mysql port for the database server  | 
| bastion_port  | ssh port for bastion server  |

To download project files to your local system, you need to execute
```sh
git clone https://github.com/sreenidhiramachandran/terraform_multi_tier_wordpress_deployment.git
```

To run this terraform code; you need to execute

```sh
$ terraform init
$ terraform plan
$ terraform apply
```

## Conclusion

This guide will walk you through the steps to create a Virtual Private Cloud (VPC) in AWS using the terraform. We will create a VPC with public and  private subnets, a NAT Gateway, an Internet Gateway, and two Route Tables. We will launch a bastion instance on the first public subnet, a frontend webserver on the second public subnet, and a database server on the private subnet.
