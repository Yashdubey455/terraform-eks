resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = "1.30"

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    )

    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = var.cluster_name
  }
}

# ---------------- OIDC PROVIDER ----------------

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# ---------------- NODE GROUP ----------------

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "student-nodes"

  node_role_arn = aws_iam_role.node_role.arn

  subnet_ids = aws_subnet.private[*].id

  instance_types = ["t3.small"]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.ecr_readonly,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ssm_policy
  ]

  tags = {
    Name = "student-node-group"

    "karpenter.sh/discovery" = var.cluster_name
  }
}
