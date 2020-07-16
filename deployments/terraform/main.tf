provider "aws" {}
resource "aws_instance" "jenkins" {
  ami           = "ami-0f24a0c4ab962365f"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}
