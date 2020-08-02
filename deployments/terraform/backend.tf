terraform {
    backend "s3" {
        bucket = "jenkins-instance-beck"
        key = "jenkins/us-east-1/hw2/dev/infrastructure.tfstate"
        region = "us-east-1"
 
    }
}