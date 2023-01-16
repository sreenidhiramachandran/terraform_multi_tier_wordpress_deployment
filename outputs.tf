output "Website_URL" {
  value = "http://${aws_route53_record.website.name}"
}

output "Webserver_Public_IP" {
  value = aws_instance.frontend.public_ip
}

output "vpc-module-return" {
  value = module.vpc
}
