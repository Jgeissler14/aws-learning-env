# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["packer-demo"]
#   }
# }

# resource "aws_instance" "instance1" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = "t2.micro"
#   key_name                    = "aws-learning-env"
#   associate_public_ip_address = true
# }

resource "aws_instance" "windows_server" {
  ami                         = "ami-03db23f7d74959cbb"
  instance_type               = "t2.small"
  key_name                    = "aws-learning-env-west"
  associate_public_ip_address = true
}
