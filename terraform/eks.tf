resource "aws_eks_cluster" "diploma-cluster" {
  name     = var.entity_name
  role_arn = data.aws_iam_role.eks-role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.diploma-subnets.ids
    endpoint_private_access = true
    endpoint_public_access = true
  }
  
  depends_on = [aws_cloudwatch_log_group.diploma-lg]
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

resource "aws_eks_addon" "vpccni" {
  depends_on   = [aws_eks_node_group.diploma-ng]
  cluster_name = aws_eks_cluster.diploma-cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  depends_on   = [aws_eks_node_group.diploma-ng]
  cluster_name = aws_eks_cluster.diploma-cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kubeproxy" {
  depends_on   = [aws_eks_node_group.diploma-ng]
  cluster_name = aws_eks_cluster.diploma-cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_node_group" "diploma-ng" {
  cluster_name    = aws_eks_cluster.diploma-cluster.name
  node_group_name = "${var.entity_name}-ng"
  node_role_arn   = data.aws_iam_role.nodegroup-role.arn
  subnet_ids      = data.aws_subnets.diploma-subnets.ids
  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }
  ami_type = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  disk_size = 8
  instance_types = ["t3.medium"]
  update_config {
    max_unavailable = 1
  }
}

resource "kubectl_manifest" "metrics-server" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  for_each = data.kubectl_file_documents.metrics-manifest.manifests
  yaml_body = each.value
}

