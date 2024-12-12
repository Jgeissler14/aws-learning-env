packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Define local variables to create dynamic suffix
locals {
  timestamp_suffix = format("%s-%s", formatdate("YYYYMMDD", timestamp()), formatdate("HHmmss", timestamp()))
}

source "amazon-ebs" "ubuntu" {
  ami_name = "packer-youtube-demo-${local.timestamp_suffix}"

  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "ami-0e86e20dae9224db8"
  ssh_username  = "ubuntu"
}

build {
  name    = "basic-amazon-image"
  sources = ["source.amazon-ebs.ubuntu"]

  # runs on ec2
  # provisioner "ansible-local" {
  #   playbook_file = "setup.yml"
  #   role_paths = [
  #     "path/to/your/roles"
  #   ]
  #   extra_arguments = ["--variable-name", "value"]
  # }

  # runs on local machine where packer is run
  provisioner "ansible" {
    playbook_file       = "setup.yml"
    use_proxy           = false
    host_alias          = "${build.Host}"
    keep_inventory_file = true
    # roles_path = "roles"
    # extra_arguments = ["--variable-name", "value"]
  }
}
