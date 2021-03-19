# If you don't set a default, then you will need to provide the variable
# at run time using the command line, or set it in the environment. For more
# information about the various options for setting variables, see the template
# [reference documentation](https://www.packer.io/docs/templates)
variable "ami_name" {
  type    = string
  default = "bastion-ami"
}


locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
source "amazon-ebs" "bastion" {
  ami_name      = "bastion-ami"
  vpc_id= "vpc-073f9d01e7a1a8b1c"
  subnet_id= "subnet-0e03dbe5aa8560fff"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-ebs"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = ["amazon"]
  }
  ssh_username = "ec2-user"
  force_deregister=true
  force_delete_snapshot=true 
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.bastion"]
  provisioner "ansible" {
    playbook_file   = "./playbook_bastion.yml"
    user="ec2-user"
  }
}