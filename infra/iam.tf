# --- This file defines the IAM roles and policies required for the EKS cluster and its worker nodes. It creates an IAM role for the EKS cluster with the necessary trust policy, attaches the AmazonEKSClusterPolicy to it, and creates an IAM role for the worker nodes with the required trust policy and attaches the AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, and AmazonEC2ContainerRegistryReadOnly policies. Additionally, it sets up an OIDC provider for the EKS cluster and creates an IAM role for the EBS CSI driver with the appropriate trust policy and policy attachment. Finally, it creates an IAM role for GitHub Actions to access the EKS cluster with a trust policy and a policy allowing it to describe the cluster.
# --- Este archivo define los roles y políticas de IAM necesarios para el clúster EKS y sus nodos de trabajo. Crea un rol de IAM para el clúster EKS con la política de confianza necesaria, adjunta la AmazonEKSClusterPolicy a él, y crea un rol de IAM para los nodos de trabajo con la política de confianza requerida y adjunta las políticas AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy y AmazonEC2ContainerRegistryReadOnly. Además, configura un proveedor OIDC para el clúster EKS y crea un rol de IAM para el controlador CSI de EBS con la política de confianza apropiada y la política adjunta. Finalmente, crea un rol de IAM para GitHub Actions para acceder al clúster EKS con una política de confianza y una política que le permite describir el clúster.

# --- Resource for the EKS Cluster IAM Role ---
# --- Recurso para el rol de IAM del clúster EKS ---
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# --- Resource for the EKS Cluster IAM Role Policy Attachment ---
# --- Recurso para la política de adjunto del rol de IAM del clúster EKS ---
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- Resource for the EKS Node IAM Role ---
# --- Recurso para el rol de IAM del nodo EKS ---
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# --- Resource for the EKS Node IAM Role Policy Attachments ---
# --- Recurso para las políticas de adjunto del rol de IAM del nodo EKS ---
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# --- Resource for cni policy attachment for EKS Node IAM Role ---
# --- Recurso para la política de adjunto cni para el rol de IAM del nodo EKS ---
resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# --- Resource for registry policy attachment for EKS Node IAM Role ---
# --- Recurso para la política de adjunto del registro para el rol de IAM del nodo
resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# --- Resource for the EKS OIDC Provider ---
# --- Recurso para el proveedor OIDC de EKS ---
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# --- Resource for openid connect provider for EKS ---
# --- Recurso para el proveedor de conexión abierta para EKS ---
resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}
data "aws_iam_policy_document" "ebs_csi_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# --- Resource for the EBS CSI Driver IAM Role ---
# --- Recurso para el rol de IAM del controlador CSI de EBS ---
resource "aws_iam_role" "ebs_csi_driver" {
  name               = "proyecto5-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust.json
}

# --- Resource for the EBS CSI Driver IAM Role Policy Attachment ---
# --- Recurso para la política de adjunto del rol de IAM del controlador CSI de EBS ---
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# --- Resource for the EKS Addon for EBS CSI Driver ---
# --- Recurso para el complemento EKS para el controlador CSI de EBS ---
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name                = "aws-ebs-csi-driver"
  service_account_role_arn  = aws_iam_role.ebs_csi_driver.arn
  resolve_conflicts_on_update = "OVERWRITE"
}

# --- Resource for the EKS Cluster Access Entry for GitHub Actions ---
# --- Recurso para la entrada de acceso al clúster EKS para GitHub Actions
data "aws_iam_policy_document" "github_actions_eks_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::700213287974:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:mamoros-dev@55656115/aws-eks-wordpress@1337678340:*"]
    }
  }
}

# --- Resource for the GitHub Actions IAM Role ---
# --- Recurso para el rol IAM de GitHub Actions ---
resource "aws_iam_role" "github_actions_eks" {
  name               = "proyecto5-github-actions-eks-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_eks_trust.json
}

# --- Resource for the GitHub Actions IAM Role Policy Attachment ---
# --- Recurso para la política de adjunto del rol IAM de GitHub Actions ---
resource "aws_iam_role_policy" "github_actions_eks_access" {
  name = "eks-describe-access"
  role = aws_iam_role.github_actions_eks.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = aws_eks_cluster.main.arn
      }
    ]
  })
}