# export Application load balancer SG
output "alb_sg_id" {
  value = aws_security_group.alb_security_group.id
}

# export Bastion SG
output "bastion_sg_id" {
  value = aws_security_group.bastion_security_group.id
}

# export Application webserver SG
output "application_sg_id" {
  value = aws_security_group.app_server_security_group.id
}

# export Database SG
output "database_sg_id" {
  value = aws_security_group.database_security_group.id
}

