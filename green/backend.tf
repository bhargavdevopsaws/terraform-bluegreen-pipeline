terraform {
  backend "s3" {
    bucket         = "terraform-eks-cicd-4583"   
    key            = "green/terraform.tfstate" 
    region         = "ap-south-1"              
  }
}
