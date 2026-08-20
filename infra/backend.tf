terraform {
  backend "s3" {
    bucket       = "miguel-terraform-state-proyecto2"
    key          = "proyecto5/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
