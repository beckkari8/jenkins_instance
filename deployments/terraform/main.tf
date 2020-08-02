provider "aws" {}
resource "aws_instance" "jenkins" {
  ami           = "${AMI_ID}"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}
