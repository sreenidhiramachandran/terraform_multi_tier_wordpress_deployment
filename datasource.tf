data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "mydomain" {
  name         = var.wp_domain
  private_zone = false
}

data "template_file" "frontend" {
  template = file("${path.module}/frontend.sh")
  vars = {
    DB_NAME   = var.db_name
    DB_USER   = var.db_username
    DB_PASSWD = var.db_password
    DB_HOST   = local.db_host
  }
}

data "template_file" "backend" {
  template = file("${path.module}/backend.sh")
  vars = {
    MYSQL_PASSWD = var.mysqlrootpwd
    DB_NAME      = var.db_name
    DB_USER      = var.db_username
    DB_PASSWD    = var.db_password
  }
}
