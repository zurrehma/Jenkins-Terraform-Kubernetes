terraform {
    source = "../../modules/jenkins"
}

include {
    path = find_in_parent_folders()
}

// dependency "nlb"{
//   config_path = "../nlb"
// }

dependency "eks"{
  config_path = "../eks"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.yaml"))
}

inputs = {
  cluster_id = dependency.eks.outputs.context.cluster_id
  controller_nodeport = local.common_vars.locals.jenkins_port
  jenkins_admin_user = local.common_vars.locals.jenkins_admin_user
  jenkins_admin_password = local.common_vars.locals.jenkins_admin_password
  // external_lb_dns_name = dependency.nlb.outputs.lb_context.dns_name
}
