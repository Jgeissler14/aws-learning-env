packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-demo"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "ami-0e86e20dae9224db8"
  ssh_username  = "ubuntu"
}

build {
  name    = "basic-amazon-image"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo ufw allow proto tcp from any to any port 22,80,443",
      "echo 'y' | sudo ufw enable"
    ]
  }

  post-processor "vagrant" {}
  post-processor "compress" {}
}
