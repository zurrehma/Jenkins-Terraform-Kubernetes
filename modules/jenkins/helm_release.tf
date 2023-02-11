data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "for i in `seq 1 60`; do wget --no-check-certificate -O - -q $ENDPOINT/healthz >/dev/null && exit 0 || true; sleep 5; done; echo TIMEOUT && exit 1"
    interpreter = [
      "/bin/sh",
      "-c"
    ]
    environment = {
      ENDPOINT = data.aws_eks_cluster.cluster.endpoint
    }
  }
}

resource "helm_release" "jenkins" {
  depends_on = [
    null_resource.wait_for_cluster,
    kubernetes_namespace.jenkins,
  ]
  name       = "jenkins"
  repository = var.chart_url
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = var.namespace_name
  values = [
    "${file("jenkins-values.yaml")}"
  ]

  set_sensitive {
    name  = "controller.adminUser"
    value = var.jenkins_admin_user
  }

  set_sensitive {
    name  = "controller.adminPassword"
    value = var.jenkins_admin_password
  }

}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace_name

    labels = {
      name        = "jenkins"
      description = "jenkins"
    }
  }
}
