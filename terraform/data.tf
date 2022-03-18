data "aws_vpc" "main-vpc" {
    default = true
}

data "aws_subnets" "diploma-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main-vpc.id]
  }
}

data "aws_iam_role" "eks-role" {
  name = "eks_role"
}

data "aws_iam_role" "nodegroup-role" {
  name = "EKS_nodegroup_role"
}

data "aws_security_group" "ingress-sg" {
    vpc_id = data.aws_vpc.main-vpc.id
    name = var.ingress_sg
}

data "aws_instances" "nodes" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  instance_tags = {
    "eks:cluster-name" = var.entity_name
  }
}

data "aws_ecr_authorization_token" "ecr-creds" {
  registry_id = aws_ecr_repository.diploma-repo.registry_id
}

data "kubectl_file_documents" "metrics-manifest" {
    content = file("metrics.yaml")
}