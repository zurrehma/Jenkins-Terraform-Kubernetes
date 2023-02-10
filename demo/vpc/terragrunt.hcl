terraform {
    source = "../../modules/vpc"
}

include {
    path = find_in_parent_folders()
}


locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.yaml"))
}

inputs = {
  cidr_b_block = 130
//   aws_region = local.common_vars.locals.region
  vpc_name = local.common_vars.locals.vpc_name
  tags = local.common_vars.locals.tags
}
