terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    external = {
      source  = "hashicorp/external"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">=1.7.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.region
    default_tags {
    tags = {
      owner = var.owner
    }
  }
}


provider "kubernetes" {
  host                   = aws_eks_cluster.diploma-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.diploma-cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.entity_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.diploma-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.diploma-cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.entity_name]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = aws_eks_cluster.diploma-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.diploma-cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.entity_name]
    command     = "aws"
  }
}