#===========================================================================================================
# Defining terraform module to create a VPC
#===========================================================================================================
module "vpc" {
  source      = "/vpc-module/"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

#===========================================================================================================
# creating a prefix list
#===========================================================================================================
resource "aws_ec2_managed_prefix_list" "new_prefix_list" {
  name           = "${var.project}-${var.environment}-prefix-list"
  address_family = "IPv4"
  max_entries    = length(var.public_ips)
  dynamic "entry" {
    for_each = var.public_ips
    iterator = allow_access_to_ip
    content {
      cidr = allow_access_to_ip.value
    }
  }
  tags = {
    "Name" = "${var.project}-${var.environment}-bastion"
  }
}

#===========================================================================================================
# creating a security group for the bastion server
#===========================================================================================================
resource "aws_security_group" "sg-bastion" {
  vpc_id      = module.vpc.vpc_id
  name        = "${var.project}-${var.environment}-bastion"
  description = "Allow SSH traffic to frontend and backend servers"
  ingress {
    from_port       = var.bastion_port
    to_port         = var.bastion_port
    protocol        = "tcp"
    prefix_list_ids = [aws_ec2_managed_prefix_list.new_prefix_list.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "${var.project}-${var.environment}-bastion"
  }
}
  
#===========================================================================================================
# creating a security group for the frontend webserver
#===========================================================================================================
resource "aws_security_group" "sg-frontend" {
  vpc_id      = module.vpc.vpc_id
  name        = "${var.project}-${var.environment}-frontend"
  description = "Allow HTTPS and HTTP from all, 22 from bastion"
  ingress {
    from_port       = var.bastion_port
    to_port         = var.bastion_port
    protocol        = "tcp"
    cidr_blocks     = var.public_ssh_to_frontend == true ? ["0.0.0.0/0"] : null
    security_groups = [aws_security_group.sg-bastion.id]
  }

  dynamic "ingress" {
    for_each = toset(var.frontend_ports)
    iterator = public_port
    content {
      from_port        = public_port.value
      to_port          = public_port.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "${var.project}-${var.environment}-frontend"
  }
}

#===========================================================================================================
# creating a security group for the backend database server
#===========================================================================================================
resource "aws_security_group" "sg-backend" {
  vpc_id      = module.vpc.vpc_id
  name        = "${var.project}-${var.environment}-webserver"
  description = "Allow 22 from bastion, 3306 from frontend"
  ingress {
    from_port       = var.bastion_port
    to_port         = var.bastion_port
    protocol        = "tcp"
    cidr_blocks     = var.public_ssh_to_backend == true ? ["0.0.0.0/0"] : null
    security_groups = [aws_security_group.sg-bastion.id]
  }
  ingress {
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-frontend.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "${var.project}-${var.environment}-backend"
  }
}

#===========================================================================================================
# Genearting a secure private key 
#===========================================================================================================
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
  
#===========================================================================================================
# Importing ssh key
#===========================================================================================================
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.project}-${var.environment}"
  public_key = tls_private_key.key.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ./mysshkey.pem ; chmod 400 ./mysshkey.pem"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ./mysshkey.pem"
  }
  tags = {
    "Name" = "${var.project}-${var.environment}"
  }
}

#===========================================================================================================
# creating a bastion instance
#===========================================================================================================
resource "aws_instance" "bastion" {
  instance_type          = var.instance_type
  ami                    = var.instance_ami
  subnet_id              = module.vpc.public_subnets.0
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg-bastion.id]
  tags = {
    "Name" = "${var.project}-${var.environment}-bastion"
  }
}
  
#===========================================================================================================
# creating a frontend instance
#===========================================================================================================
resource "aws_instance" "frontend" {
  instance_type               = var.instance_type
  ami                         = var.instance_ami
  subnet_id                   = module.vpc.public_subnets.1
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.sg-frontend.id]
  user_data                   = data.template_file.frontend.rendered
  user_data_replace_on_change = true
  depends_on                  = [aws_instance.backend]
  tags = {
    "Name" = "${var.project}-${var.environment}-frontend"
  }
}

#===========================================================================================================
# creating a backend instance
#===========================================================================================================
resource "aws_instance" "backend" {
  instance_type               = var.instance_type
  ami                         = var.instance_ami
  subnet_id                   = module.vpc.private_subnets.0
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.sg-backend.id]
  user_data                   = data.template_file.backend.rendered
  user_data_replace_on_change = true
  depends_on                  = [module.vpc]
  tags = {
    "Name" = "${var.project}-${var.environment}-backend"
  }
}

#===========================================================================================================
#creating a private hosted zone
#===========================================================================================================
resource "aws_route53_zone" "privatezone" {
  name = var.private_zone
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

#===========================================================================================================
#creating an A record in the private hosted zone pointing to the backend server's private IP
#===========================================================================================================
resource "aws_route53_record" "database" {
  zone_id = aws_route53_zone.privatezone.zone_id
  name    = "db.${var.private_zone}"
  type    = "A"
  ttl     = 5
  records = [aws_instance.backend.private_ip]
}

#===========================================================================================================
#creating an A record in the public hosted zone pointing to the frontend server's public IP
#===========================================================================================================
resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "wordpress.${var.wp_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.frontend.public_ip]
}
