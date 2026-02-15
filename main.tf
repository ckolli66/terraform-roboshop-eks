resource "aws_eks_cluster" "example" {
  name = "example"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.34"

  vpc_config {
	subnet_ids = ["subnet-0edfbefd92844afcd","subnet-0301e9e21d6e797cf"]
  }
  access_config {
	authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group"  "example" {
  cluster_name = aws_eks_cluster.example
  node_group_name = "example"
  node_role_arn   = aws_iam_role.example.arn
  subnet_ids      = ["subnet-0edfbefd92844afcd","subnet-0301e9e21d6e797cf"]

  scaling_config {
	desired_size = 1
	max_size     = 2
	min_size     = 1
  }

  update_config {
	max_unavailable = 1
  }
}