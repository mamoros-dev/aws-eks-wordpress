variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
  default     = "proyecto5-wordpress"
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes del control plane, fijada explícitamente"
  type        = string
  default     = "1.31"
}

variable "azs" {
  description = "Zonas de disponibilidad a usar"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}