resource "aws_eks_addon" "pod-identity" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "external-dns" {
  depends_on = [aws_eks_addon.pod-identity]
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "external-dns"
}

resource "aws_eks_pod_identity_association" "example" {
  cluster_name    = aws_eks_cluster.example.name
  namespace       = "default"
  service_account = "default"
  role_arn        = aws_iam_role.example.arn
}