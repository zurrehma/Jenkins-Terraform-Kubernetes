#------------------------------------------------------------------------------
# jenkins variables
#------------------------------------------------------------------------------
variable "chart_url" {
  type    = string
  default = "https://charts.jenkins.io"
}

variable "chart_version" {
  type    = string
  default = "4.2.17"
}

variable "cluster_id" {
  type = string
}

variable "namespace_name" {
  type    = string
  default = "jenkins"
}

variable "controller_nodeport" {
  type = number
}

# ------------------------------------------------------------
# Jenkins Settings
# ------------------------------------------------------------
variable "jenkins_admin_user" {
  type        = string
  description = "Admin user of the Jenkins Application."
  default     = "admin"
}

variable "jenkins_admin_password" {
  type        = string
  description = "Admin password of the Jenkins Application."
  default     = "Admin@123"
}

