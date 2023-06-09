# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance_az1" {
  ami                    = data.aws_ami.amazon_linux_2.id # need to be replaced by this id: ami-09988af04120b3591
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_az1_id
  vpc_security_group_ids = [var.application_sg_id]
  key_name               = var.key_name
  user_data              = file("conf/install_rentzone.sh")

  tags = {
    Name = "${var.project_name} | Rentzone Web App AZ1"
  }
}

resource "null_resource" "file_transport" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/hiro/Documents/AOS_docs/dynamic-ecommerce/hiro_kp.pem")
    host        = aws_instance.ec2_instance_az1.public_ip
  }

  provisioner "file" {
    source      = "/home/hiro/Documents/AOS_docs/dynamic-web-app-terraform-modules-rentzone/rentzone-infrastructure/conf/install_rentzone.sh"
    destination = "/home/ec2-user/install_rentzone.sh"
  }

  depends_on = [ aws_instance.ec2_instance_az1 ]
}


# launch the ec2 instance and install website
# resource "aws_instance" "ec2_instance_az2" {
#   ami                    = data.aws_ami.amazon_linux_2.id
#   instance_type          = var.instance_type
#   subnet_id              = var.public_subnet_az2_id
#   vpc_security_group_ids = [var.application_sg_id]
#   key_name               = var.key_name
#   user_data              = file("conf/install_rentzone.sh")
  

#   tags = {
#     Name = "${var.project_name} | Rentzone Web App AZ2"
#   }

#   connection {
#     type = "ssh"
#     user        = "ec2-user"
#     private_key = "${file("/home/hiro/Documents/AOS_docs/dynamic-ecommerce/hiro_kp.pem")}"
#     host = "${self.public_ip}"
#   } 

#   # Copies the conf files file to /home/ec2-user
#   provisioner "file" {
#     source      = "/home/hiro/Documents/AOS_docs/dynamic-web-app-terraform-modules-rentzone/rentzone-infrastructure/conf/install_rentzone.sh"
#     destination = "/home/ec2-user/install_rentzone.sh"
#   }
# }



# print the ec2's public ipv4 address
output "public_ipv4_address" {
  value = aws_instance.ec2_instance_az1.public_ip
}