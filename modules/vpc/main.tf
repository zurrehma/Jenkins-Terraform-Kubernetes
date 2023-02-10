module "label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  namespace   = var.namespace
  environment = var.environment
  attributes  = var.attributes
  enabled     = var.enabled
  tags        = var.tags
  stage       = var.stage
  name        = var.name
}

locals {
  cidr            = "10.${var.cidr_b_block}.0.0/16"
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  subnets         = cidrsubnets(local.cidr, 8, 8, 8, 8, )
  private_subnets = slice(local.subnets, 0, 2)
  public_subnets  = slice(local.subnets, 2, 4)

  tags = merge(module.label.tags, var.tags)
}

resource "aws_eip" "nat" {
  count = length(local.azs)

  vpc  = true
  tags = local.tags
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = var.vpc_name
  cidr = local.cidr
  azs  = local.azs

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_vpn_gateway = false

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # Skip creation of EIPs for the NAT Gateways, use the ones created in this
  # module. This lets us keep the same IPs even after the VPC is destroyed and
  # re-created
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id
  # Manage default security group of the VPC to be able to enable incoming
  # traffic from VPC CIDR
  # manage_default_security_group = true
  # default_security_group_ingress = [
  #   {
  #     self        = true,
  #     description = "Enable all incoming traffic from self"
  #     protocol    = "-1"
  #   },
  #   {
  #     cidr_blocks = local.cidr
  #     description = "Enable all incoming traffic from the VPC CIDR"
  #     protocol    = "-1"
  #   },
  # ]
  # default_security_group_egress = [
  #   {
  #     description = "Enable all outgoing traffic"
  #     cidr_blocks = "0.0.0.0/0"
  #     protocol    = "-1"
  #   },
  # ]

  tags = local.tags
}
