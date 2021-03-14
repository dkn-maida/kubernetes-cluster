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