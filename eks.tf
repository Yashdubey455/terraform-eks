resource "aws_eks_cluster" "eks" {
  name     = "student-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.subnet[*].id
  }
}
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "student-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_subnet.subnet[*].id

  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}

