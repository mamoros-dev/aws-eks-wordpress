# --- This file defines the output values for the Terraform configuration. It includes outputs for the EKS cluster name, cluster endpoint, NAT gateway public IP, and a command to configure kubectl for accessing the EKS cluster. These outputs provide useful information after the infrastructure is created, allowing users to easily retrieve important details about the deployed resources.
# --- Este archivo define los valores de salida para la configuración de Terraform. Incluye salidas para el nombre del clúster EKS, el endpoint del clúster, la IP pública de la puerta de enlace NAT y un comando para configurar kubectl para acceder al clúster EKS. Estas salidas proporcionan información útil después de que se crea la infraestructura, lo que permite a los usuarios recuperar fácilmente detalles importantes sobre los recursos implementados.
output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat.public_ip
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region eu-west-1 --name ${aws_eks_cluster.main.name} --profile personal"
}