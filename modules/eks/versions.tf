provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

terraform {
  required_providers {
    aws = {
      version = "~> 4.21.0"
    }
    kubernetes = {
      version = "2.12.1"
    }
  }
  required_version = "~> 1.2.6"
}