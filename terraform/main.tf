provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

#bucket pour le remote state
resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = "terraform-remote-state-storage-s3-kubernetes-cluster"
    versioning {
      enabled = true
    }
    lifecycle {
      prevent_destroy = false
    }
    tags = {
      Name = "S3 Remote Terraform State Store"
    }      
}

#table dynamo pour le lock
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
  tags= {
    Name = "DynamoDB Terraform State Lock Table kubernetes cluster"
  }  
}

#conf du backend avec le bucket pour les states et la table dynamo pour le lock, en commentaire à la premiere execution
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-storage-s3-kubernetes-cluster"
    dynamodb_table = "terraform-state-lock-dynamo"
    key    = "state"
    region = "us-east-1"
    encrypt = true
  }
}


#network
module "network" {
  source = "./modules/network"
  vpc_cidr_block = "10.0.0.0/16"
  private_subnet_cidr_block="10.0.2.0/24"
  public_subnet_cidr_block="10.0.1.0/24"
}

#bastion
module "bastion" {
  source = "./modules/bastion"
  bastion_ip = "10.0.2.4"
  vpc_id=module.network.vpc_id
  public_subnet_id=module.network.public_subnet_id
}

#cluster
module "cluster" {
  source = "./modules/cluster"
  control_pane_1_ip = "10.0.1.4"
  control_pane_2_ip="10.0.1.5"
  worker_1_ip="10.0.1.11"
  worker_2_ip="10.0.1.12"
  worker_3_ip="10.0.1.13"
  vpc_id=module.network.vpc_id
  public_subnet_id=module.network.public_subnet_id
  private_subnet_id=module.network.private_subnet_id
  public_subnet_cidr_block=module.network.public_subnet_cidr_block
  private_subnet_cidr_block=module.network.public_subnet_cidr_block
  bastion_ip=module.bastion.bastion_ip
}