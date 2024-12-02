output "eks_cluster_name" {
  value = aws_eks_cluster.eks_eks.id
}

output "irsa_role_arn" {
  value = aws_iam_role.external-dns-irsa-role.arn
}