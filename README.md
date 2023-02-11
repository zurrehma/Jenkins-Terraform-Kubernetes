# Jenkins Deployment on EKS
This repository contains files to create resources required to host Jenkins on AWS EKS.

## PreRequisits
Following tools need to be installed.
| Name | Version |
|------|---------|
| terraform | >= 1.2.6 |
| terragrunt | v0.38.0 |

To install the above requirements, the following command can be executed on Debian systems  
***Terraform***
```
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
```

***Terragrunt***
```
curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
tgswitch 0.38.0
```
The code is divided into modules and follows the best practices. Terragrunt helps in making the setup DRY(Don't Repeat Yourself).
## Directory Structure
#### modules
The modules directory contains all terraform modules.
| Module | Description |
|------|-------------|
| vpc | This module create AWS vpc |
| eks | This module create AWS EKS cluster |
| jenkins | This module create Kubernetes resources to deploy Jenkins |

#### demo
The demo directory contains the terragrunt files which will be used to create the whole setup.
| Directory | Description |
|------|-------------|
| vpc | contains terragrunt file to create vpc resources |
| eks | contains terragrunt file to create eks resources |
| jenkins | contains terragrunt file to create Jenkins resources |

## Task: Set up a Jenkins master and worker configuration on a Kubernetes cluster of your choice. 

- [x] All configuration needs to be done with Terraform 
- [x] The deployment needs to be fully automated 
- [x] Orchestrated by Kubernetes, the workers need to be dynamically created on demand 

#### Recommendations
* The cluster autoscaler or karpenter can be used to scale workers on load.
* The taints and tolerations can be added so no worker pod is scheduled on the Jenkins controller instance.
* The monitoring can be improved by adding observability tools such as Prometheus for metrics logs and ELK for logs
* The authentication can be integrated with IAM using IAM authenticator and using aws-auth configmap on EKS side.
* The Kubernetes Service account permission to AWS services can be limited by using OIDC Provided URL by EKS with IAM.
* The Jenkins storage persistence can be changed to efs type to fully utilize the autoscaling.

#### Deployment Commands:
The demo directory will be used to deploy the whole setup.
For cloud resources, Terraform module [terraform-null-label](https://github.com/terraform-aws-modules/terraform-aws-eks/) is used to generate consistent names and tags for the resources. 
* Use ***demo/account.yaml*** to create consistent names. 
* Use ***demo/common_vars.yaml*** to update different module variables according to each environment.

Once tools are installed. Use ***aws configure*** to set up your connectivity with AWS cloud.
By default, resources are created inside ***us-east-1*** region. It can be updated inside ***demo/terragrunt.hcl*** file.
The state file is stored on s3 bucket.  
To initialize the backend first, use the below command in the demo root directory.
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
cd demo/jenkins
terragrunt apply
```
***To connect with EKS cluster:***  
Access Jenkins using the load balancer DNS name and port 8080, the DNS name can be obtained using the below command or by visiting AWS console. Wait for some time if the URL is not accessible, the health check initialization takes some time.
```
kubectl get svc -n jenkins
```
The Jenkins username and password can be obtained from ***demo/common_vars.yaml*** file.


## Task: Create a job and build it using this infrastructure. 
I have created a [jenkins-cicd-example](https://github.com/zurrehma/jenkins-cicd-example) repository on my GitHub account. It contains a basic ***Go*** app. The code and deployment files are compiled from different sources.

> **Note**
> The below ***Steps to deploy complete ci/cd job*** steps deploy full ci/cd pipeline. The repo clone  and integrating docker hub part is optional, if just testing of jenkins worker execution is intended, follow [Steps to check only worker execution:](#steps-to-check-only-worker-execution) steps.

#### Steps to deploy complete ci/cd job:
* Clone the source repo and ***cd*** into it. Apply the ***docker-in-docker.yaml*** file to create a docker container used for building docker images.
```
kubectl apply -f ./setup/docker-in-docker.yaml
```
* Go to `Jenkins > Dashboard > Manage Jenkins > Manage Credentials > System > Global credentials > Add Credentials`, select kind `Username and password` and fill in. Set the label to ***docker-creds*** as this is by default set in Jenkinsfile to read credentials.
  * Username will be the docker hub username.
  * Password will be the docker hub password or token.

* Create a repository with the name **jenkins-cicd-example** in docker hub, otherwise, change this variable ***def REPO_NAME = your-repo-name*** in Jenkinsfile to use a different name.

* Change the owner variable ***def OWNER = your-user-name*** in Jenkinsfile to your docker hub user name.

* push the changes to GitHub repository.

* create the Jenkins job of type pipeline. 
    * In ***Build Triggers***, select ***Poll SCM*** option and select the schedule to ***\* \* \* \* \****.
    * In Pipeline configuration use ***Pipeline Script from SCM*** and select ***git*** as an SCM. Pass the repository details and set the script path as ***Jenkinsfile***. 

* Push some changes to the repository or manually build the pipeline.

Once Successful, copy the pushed image tag and update the ***docker-compose.yaml*** file in the directory. Execute the below command and access ***localhost:9094***.
```
sudo docker compose up
```

#### Steps to check only worker execution:  
Same GitHub repo can be used as a git SCM with ***jenkins/Jenkinsfile*** as a path to Jenkinsfile. This will just build the docker image from the same repo.
* Apply the ***docker-in-docker.yaml*** file from the repo to create a docker container used for building docker images. It can be copied from the [jenkins-cicd-example](https://github.com/zurrehma/jenkins-cicd-example) repo. The file is located in the setup directory.
```
kubectl apply -f docker-in-docker.yaml
```
* create the Jenkins job of type pipeline.
    * In Pipeline configuration use ***Pipeline Script from SCM*** and select ***git*** as an SCM. Pass the repository details and set the script path as ***jenkins/Jenkinsfile***. Finally, build the job.
