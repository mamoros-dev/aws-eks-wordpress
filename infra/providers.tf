# --- This file defines the AWS provider configuration for Terraform. It specifies the required version of Terraform and the AWS provider, as well as the AWS region to be used for resource creation. The provider block configures the AWS provider with the specified region (eu-west-1) for all resources defined in this Terraform configuration.
# --- Este archivo define la configuración del proveedor de AWS para Terraform. Especifica la versión requerida de Terraform y el proveedor de AWS, así como la región de AWS que se utilizará para la creación de recursos. El bloque del proveedor configura el proveedor de AWS con la región especificada (eu-west-1) para todos los recursos definidos en esta configuración de Terraform.
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}