# --- This file defines the backend configuration for Terraform. It specifies that the state of the Terraform-managed infrastructure will be stored in an S3 bucket named "miguel-terraform-state-proyecto2" in the "eu-west-1" region. The state file will be stored at the key "proyecto5/terraform.tfstate". The configuration also enables state locking to prevent concurrent modifications and encrypts the state file for security.
# --- Este archivo define la configuración del backend para Terraform. Especifica que el estado de la infraestructura administrada por Terraform se almacenará en un bucket de S3 llamado "miguel-terraform-state-proyecto2" en la región "eu-west-1". El archivo de estado se almacenará en la clave "proyecto5/terraform.tfstate". La configuración también habilita el bloqueo del estado para evitar modificaciones concurrentes y cifra el archivo de estado para mayor seguridad.
terraform {
  backend "s3" {
    bucket       = "miguel-terraform-state-proyecto2"
    key          = "proyecto5/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
