# jenkins


This module contains Terraform code to create an Jenkins resources on EKS

It uses [jenkins-helm-chart](https://charts.jenkins.io).

## Terraform Docs

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

## Requirements
| Name | Version |
|------|---------|
| terraform | >= 1.2.6 |
| helm | ~> 2.6.0 |
| kubernetes | ~> 2.12.1 |


## Outputs

| Name | Description |
|------|-------------|
| context | all outputs emitted by module.eks |