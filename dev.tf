provider "aws" {

  region  = "us-east-1"
  profile = "devops-koko"

}


module "vpc" {

  source = "./module/vpc"

}

module "my_subnet" {
  source             = "./module/subnet"
  vpc_id             = module.vpc.koko-vpc_id
  availability_zones = var.availability_zones
  private_subnet     = var.private_subnet
  public_subnet      = var.public_subnet


}

module "networking" {
  source                 = "./module/ec2"
  ec2_keypair            = var.ec2_keypair
  instance_type          = var.instance_type
  subnet_ids             = ["module.my_subnet.pub_subnet_id", "module.my_subnet.pri_subnet_id"]
  ec2_ami                = var.ec2_ami
  vpc_id                 = module.vpc.koko-vpc_id
  private_subnet         = var.private_subnet
  public_subnet          = var.public_subnet
  vpc_security_group_ids = ["module.ec2.security_group_public", "module.ec2.security_group_private"]
  availability_zones     = var.availability_zones



}