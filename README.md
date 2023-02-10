


# Jenkins Deployment on EKS


This reposiotry contain files to create resources required to host Jenkins on AWS EKS.

## PreRequisits
Follwing tools need to be installed.
| Name | Version |
|------|---------|
| terraform | >= 1.2.6 |
| terragrunt | v0.38.0 |

In order to install above requirments, follwing command can be exeuted on debian/ubuntu systems  
***Terraform***
```
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
```

***Terragrunt***
```
curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
tgswitch 0.38.0
```
## Directory Structure
#### modules
The modules directory contain all terraform modules.
| Module | Description |
|------|-------------|
| vpc | This module create AWS vpc |
| eks | This module create AWS EKS cluster |
| jenkins | This module create kubernetes resources to deply Jenkins |

#### demo
The demo directory contains the terragrunt files which will be used to create the whole setup.
| Directory | Description |
|------|-------------|
| vpc | contains terragrunt file to create vpc resources |
| eks | contains terragrunt file to create eks resources |
| jenkins | contains terragrunt file to create jenkins resources |

## Task: Set up a Jenkins master and worker configuration on a Kubernetes cluster of your choice.

- [x] All configuration needs to be done with Terraform 
- [x] The deployment needs to be fully automated 
- [x] Orchestrated by Kubernetes, the workers need to be dynamically created on demand 

#### Recommendations
* The cluster autoscaler or karpenter can be used to scale workers on load.
* The taints and tolerations can be added so no worker pod is scheduled on the Jenkins controller instance.
* The monitoring can be improved by adding observability tools such as Prometheus for metrics logs and ELK for logs

#### Deployment Commands:
The demo directory will be used to deploy the whole setup.
For cloud resources, Terraform module [terraform-null-label](https://github.com/terraform-aws-modules/terraform-aws-eks/) is used to generate consistent names and tags for the resources. 
* Use ***demo/account.yaml*** to create consistent names. 
* Use ***demo/common_vars.yaml*** to update tags.

Once tools are installed. Use ***aws configure*** to set up your connectivity with AWS cloud.
By default resources are created inside ***us-east-1*** region. It can be updated inside ***demo/terragrunt.hcl*** file.
The state file is stored on s3 bucket.  
To initialize the backend first, use below command in demo root directory.
```
cd demo
terragrunt init
```
To deploy VPC:
```
cd demo/vpc
terragrunt apply
```
To deploy EKS Cluster:
```
cd demo/eks
terragrunt apply
```
To deploy Jenkins resources:
The default admin user and password can be changed inside ***demo/common_vars.yaml*** file.
```
cd demo/vpc
terragrunt apply
```
To connect with EKS cluster:
```
aws eks update-kubeconfig --region us-east-1 --name jenkins-cluster
```
Access the Jenkins using load balancer dns name and port 8080, the dns name can be obtained using below command or visiting AWS console. Wait for some time if url is not accessaible, the helath check intialization take some time.
```
kubectl get svc -n jenkins
```
The Jenkins user name and password can be obtained from ***demo/common_vars.yaml*** file.






