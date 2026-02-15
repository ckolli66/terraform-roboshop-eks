resource "aws_eks_cluster" "example" {
  name = var.env
  role_arn = aws_iam_role.cluster.arn
  version  = "1.35"

  vpc_config {
	subnet_ids = ["subnet-0edfbefd92844afcd","subnet-0301e9e21d6e797cf"]
  }
  access_config {
	authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group"  "node" {
  cluster_name = aws_eks_cluster.example.name
  node_group_name = "example"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = ["subnet-0edfbefd92844afcd","subnet-0301e9e21d6e797cf"]

  scaling_config {
	desired_size = 1
	max_size     = 10
	min_size     = 1
  }

  update_config {
	max_unavailable = 1
  }
}

resource "aws_eks_access_entry" "workstation" {
  cluster_name      = aws_eks_cluster.example.name
  principal_arn     = "arn:aws:iam::444206648334:role/workstation-role"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "workstation" {
  cluster_name  = aws_eks_cluster.example.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::444206648334:role/workstation-role"

  access_scope {
	type       = "cluster"
  }
}