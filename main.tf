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
  instance_types  = ["t3.small"]
  capacity_type   = "SPOT"

  scaling_config {
	desired_size = 1
	max_size     = 10
	min_size     = 1
  }

  update_config {
	max_unavailable = 1
  }
  depends_on = [
	aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
	aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
	aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
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

resource "null_resource" "update-kubeconfig" {

  depends_on = [aws_eks_cluster.example,aws_eks_node_group.node]

  triggers = {
	cluster = timestamp()
  }
  provisioner "local-exec" {
	command = "rm -rf ~/.kube ; aws eks update-kubeconfig --name dev"
  }
}

## DB-INSTANCES INFRA

resource "aws_instance" "instances" {
  for_each               = var.components
  ami                    = var.ami
  instance_type          = var.type
  vpc_security_group_ids = [var.vpc_security_group_ids]

  tags = {
	Name = each.key
  }
}

resource "aws_route53_record" "a-records" {
  for_each = var.components
  zone_id  = var.zone_id
  name     = "${each.key}-${var.env}"
  type     = var.record_type
  ttl      = 30
  records  = [aws_instance.instances[each.key].private_ip]
}

resource "null_resource" "ansible" {
  depends_on = [aws_instance.instances,aws_route53_record.a-records]
  for_each   = var.components
  provisioner "remote-exec" {
	connection {
	  type = "ssh"
	  user = "ec2-user"
	  password = "DevOps321"
	  host = aws_instance.instances[each.key].private_ip
	}
	inline = [
	  "sudo dnf install python3.13-pip -y",
	  "sudo pip3.11 install ansible",
	  "ansible-pull -i localhost, -U https://github.com/ckolli66/roboshop-ansible-roles-v1.git main.yaml -e component=${each.key} -e env=${var.env}"
	]
  }
}


