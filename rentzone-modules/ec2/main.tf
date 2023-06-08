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
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_az1_id
  vpc_security_group_ids = var.application_sg_id
  key_name               = var.key_name
  user_data              = file("install_rentzone.sh")

  tags = {
    Name = "${var.project_name} | Rentzone Web App"
  }
}

# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_az2_id
  vpc_security_group_ids = [var.application_sg_id]
  key_name               = var.key_name
  user_data              = file("install_rentzone.sh")
  

  tags = {
    Name = "${var.project_name} | Rentzone Web App"
  }

  # Copies the conf files file to /home/ec2-user
  provisioner "file" {
    source      = "conf/install_rentzone.sh"
    destination = "/home/ec2-user"
  }
}



# print the ec2's public ipv4 address
output "public_ipv4_address" {
  value = aws_instance.ec2_instance.public_ip
}