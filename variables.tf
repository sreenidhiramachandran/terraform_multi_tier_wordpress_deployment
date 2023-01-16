variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "project" {}
variable "environment" {}
variable "instance_ami" {}
variable "instance_type" {}
variable "vpc_cidr" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "mysqlrootpwd" {}
variable "private_zone" {}
variable "wp_domain" {}

locals {
  common_tags = {
    "project"     = var.project
    "environemnt" = var.environment
  }
}

locals {
  subnets = length(data.aws_availability_zones.available.names)
}

locals {
  db_host = "db.${var.private_zone}"
}

#===========================================================================================================
# defining the list of IPs that can SSH to the bastion server
#===========================================================================================================
variable "public_ips" {
  type = list(string)
  default = [
    "X.X.X.X/X",
    "X.X.X.X/X",
    "X.X.X.X/X",
    "X.X.X.X/X",
    "X.X.X.X/X"
  ]
}

#====================================================================================
#defining two variables to make ssh access flexible for various environments
#====================================================================================
variable "public_ssh_to_frontend" {
  default = false
}

variable "public_ssh_to_backend" {
  default = false
}

#===========================================================================================================
# defining the frontend backend and bastion ports
#===========================================================================================================
variable "frontend_ports" {
  type    = list(string)
  default = ["80", "443"]
}

variable "backend_port" {
  type    = number
  default = 3306
}

variable "bastion_port" {
  type    = number
  default = 22
}
