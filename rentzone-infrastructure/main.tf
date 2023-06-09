locals {
  region       = var.region
  project_name = var.project_name
  environment  = var.environment
}

# create vpc module
module "vpc" {
  source                       = "git@github.com:Hirodari/dynamic-web-app-terraform-modules-rentzone.git//rentzone-modules/vpc"
  region                       = local.region
  project_name                 = local.project_name
  environment                  = local.environment
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr

}

# create natgateway

module "natgateway" {
  source                     = "git@github.com:Hirodari/dynamic-web-app-terraform-modules-rentzone.git//rentzone-modules/natgateway"
  project_name               = local.project_name
  environment                = local.environment
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  internet_gateway           = module.vpc.internet_gateway
  vpc_id                     = module.vpc.vpc_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}

# create Security Group

module "security-group" {
  source       = "git@github.com:Hirodari/dynamic-web-app-terraform-modules-rentzone.git//rentzone-modules/security-group"
  project_name = local.project_name
  environment  = local.environment
  vpc_id       = module.vpc.vpc_id
  ssh_ip       = var.ssh_ip
}

# create RDS

module "database" {
  source                     = "git@github.com:Hirodari/dynamic-web-app-terraform-modules-rentzone.git//rentzone-modules/rds"
  project_name               = local.project_name
  environment                = local.environment
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
  db_snapshot_identifier     = var.db_snapshot_identifier
  db_instance_class          = var.db_instance_class
  availability_zone_1        = module.vpc.availability_zone_1
  db_instance_identifier     = var.db_instance_identifier
  multi_az_deployment        = var.multi_az_deployment
  database_sg_id             = module.security-group.database_sg_id
}

# create EC2
module "ec2" {
  source               = "git@github.com:Hirodari/dynamic-web-app-terraform-modules-rentzone.git//rentzone-modules/ec2"
  project_name         = local.project_name
  instance_type        = var.instance_type
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
  application_sg_id    = module.security-group.application_sg_id
  bastion_sg_id        = module.security-group.bastion_sg_id
  key_name             = var.key_name
}
