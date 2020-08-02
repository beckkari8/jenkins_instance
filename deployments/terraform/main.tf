provider "aws" {}
resource "aws_instance" "jenkins" {
  ami           = "${params.AMI_ID}"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}
