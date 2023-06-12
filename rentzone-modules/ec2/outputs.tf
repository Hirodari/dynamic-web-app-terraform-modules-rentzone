# export ec2 ressource az 1
output "ec2_instance_az1_id" {
  value = aws_instance.ec2_instance_az1.id
}

# export ec2 ressource az 2
output "ec2_instance_az2_id" {
  value = aws_instance.ec2_instance_az2.id
}