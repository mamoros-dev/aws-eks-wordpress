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