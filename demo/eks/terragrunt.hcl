terraform {
    source = "../../modules/eks"
}

include {
    path = find_in_parent_folders()
}

dependency "vpc"{
  config_path = "../vpc"
}


locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.yaml"))
}

inputs = {
  vpc_id = dependency.vpc.outputs.context.vpc_id
  cluster_name = local.common_vars.locals.cluster_name
  subnets = dependency.vpc.outputs.context.private_subnets
  jenkins_from_port = local.common_vars.locals.jenkins_port
  jenkins_to_port = local.common_vars.locals.jenkins_port
  agent_from_port = local.common_vars.locals.agent_port
  agent_to_port = local.common_vars.locals.agent_port
  managed_node_group_sg_id = dependency.vpc.outputs.context.default_security_group_id
  tags = local.common_vars.locals.tags
}
