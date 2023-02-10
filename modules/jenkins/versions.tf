terraform {
  required_providers {
    helm = {
      version = "~> 2.6.0"
    }
    kubernetes = {
      version = "2.12.1"
    }
  }
  required_version = "~> 1.2.6"
}
