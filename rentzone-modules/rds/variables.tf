# environment variables
variable "project_name" {}
variable "environment" {}
# vpc environment
variable "private_data_subnet_az1_id" {}
variable "private_data_subnet_az2_id" {}
# rds environment
variable "db_snapshot_identifier" {}
variable "db_instance_class" {}
variable "availability_zone_1" {}
variable "db_instance_identifier" {}
variable "multi_az_deployment" {}
variable "database_sg_id" {}