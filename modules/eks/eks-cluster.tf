
module "label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  environment = var.environment
  attributes  = var.attributes
  enabled     = var.enabled
  tags        = var.tags
  stage       = var.stage
  name        = var.name
}

locals {
  tags = merge(module.label.tags, var.tags)
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.28.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.subnets
  vpc_id          = var.vpc_id

  eks_managed_node_group_defaults = {
    ami_type       = var.ami_type
    instance_types = var.worker_group_instance_type

  }

  eks_managed_node_groups = {
    blue = {
    }
    green = {
      min_size     = var.autoscaling_group_min_size
      max_size     = var.autoscaling_group_max_size
      desired_size = var.autoscaling_group_desired_capacity

      instance_types = var.worker_group_instance_type
    }
  }

  tags = local.tags
}

resource "aws_security_group_rule" "allow_all_ingress" {
  description       = "Allow incoming traffic from load balancer to Jenkins Controller"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "allow_all_egress" {
  description       = "Allow all outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.node_security_group_id
}
