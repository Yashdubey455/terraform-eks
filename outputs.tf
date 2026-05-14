output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_oidc_issuer" {
  value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
