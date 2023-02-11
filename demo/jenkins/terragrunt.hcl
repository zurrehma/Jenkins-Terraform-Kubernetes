terraform {
    source = "../../modules/jenkins"
}

include {
    path = find_in_parent_folders()
}

dependency "eks"{
  config_path = "../eks"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.yaml"))
}

inputs = {
  cluster_id = dependency.eks.outputs.context.cluster_id
  jenkins_admin_user = local.common_vars.locals.jenkins_admin_user
  jenkins_admin_password = local.common_vars.locals.jenkins_admin_password
  namespace_name = local.common_vars.locals.jenkins_namespace_name
}
