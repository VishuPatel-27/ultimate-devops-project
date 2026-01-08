# Eks-Gitops-Microservices : End-to-End DevOps Implementation

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub](https://img.shields.io/badge/GitHub-VishuPatel--27-181717?logo=github)](https://github.com/VishuPatel-27)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Vishu_Patel-0A66C2?logo=linkedin)](https://linkedin.com/in/vishupatel27)

> **Note**: This repository showcases a complete DevOps implementation of the [OpenTelemetry Demo Application](https://github.com/open-telemetry/opentelemetry-demo). The original application is licensed under Apache-2.0. This implementation adds production-grade CI/CD pipelines, infrastructure-as-code using Terraform, GitOps deployment with ArgoCD, and secure cloud infrastructure on AWS.

## Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Demo Video](#-demo-video)
- [Technologies Used](#-technologies-used)
- [Project Structure](#-project-structure)
- [Infrastructure Details](#-infrastructure-details)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Deployment Process](#-deployment-process)
- [Challenges & Solutions](#-challenges--solutions)
- [Cost Estimation](#-cost-estimation)
- [Key Learnings](#-key-learnings)
- [Acknowledgments](#-acknowledgments)
- [License](#-license)

## Project Overview

This project demonstrates a complete DevOps transformation of a microservices-based e-commerce application. The OpenTelemetry Demo application consists of 20+ microservices written in different programming languages (Go, Python, Java, Node.js, C#, etc.).

**Project Duration**: December 2024 - January 2025 (1 month)

**Key Achievements**:
-  Containerized multiple microservices with Docker best practices
-  Built production-ready CI/CD pipelines using GitHub Actions
-  Implemented Infrastructure-as-Code with Terraform custom modules and remote state management
-  Deployed highly available EKS cluster across multiple availability zones
-  Implemented GitOps workflow with ArgoCD
-  Secured applications with TLS certificates and AWS ALB
-  Configured custom domain with Route53 DNS management

## Architecture

### High-Level Architecture
![DevOps Architecture](project-architecture.png)
*Complete AWS infrastructure showing VPC, EKS, ALB, and other configurations*

### CI/CD Pipeline Architecture
![CI/CD Pipeline](CI-CD-Flow.png)
*GitHub Actions workflow with GitOps deployment using ArgoCD*

## 🎥 Demo Video

> Full project walkthrough and implementation demonstration

[![Project Demo](argocd-ingress.png)](https://youtu.be/B-X_bd7yIyM)

**Video Contents**:
- CI/CD pipeline execution
- GitOps deployment with ArgoCD
- Application demonstration
- Troubleshooting and monitoring

## Technologies Used

### Infrastructure & Cloud
- **Cloud Provider**: AWS (EKS, VPC, ALB, Route53, ACM, S3, DynamoDB)
- **Infrastructure as Code**: Terraform (v1.x) with custom modules and Remote State (S3 + DynamoDB)
- **Container Orchestration**: Kubernetes (EKS)
- **Compute**: EC2 t3.medium instances (EKS Node Groups)

### CI/CD & GitOps(app-of-apps approach: Declarative)
- **CI/CD Platform**: GitHub Actions
- **GitOps Tool**: ArgoCD
- **Container Registry**: DockerHub
- **Version Control**: Git & GitHub

### Containerization & Networking
- **Containerization**: Docker (Multi-stage builds)
- **Ingress Controller**: AWS ALB Ingress Controller
- **TLS/SSL**: AWS Certificate Manager (ACM)
- **DNS Management**: AWS Route53

### Development Tools
- **Languages**: Go (1.22), Python, Java
- **Code Quality**: static code analysis tools for respective languages
- **CLI Tools**: kubectl, eksctl, AWS CLI, terraform

## 📁 Project Structure

```
.
├── src/
│   ├── product-catalog/          # Go microservice
│   │   ├── Dockerfile
│   │   ├── main.go
│   │   └── products/
│   ├── recommendation-service/   # Python microservice
│   └── ad-service/              # Java microservice
│   ...                          # other services
|                            
├── infra/
│   ├── backend/                 # S3 + DynamoDB remote state
│   │   ├── main.tf                 
│   │   └── outputs.tf                
│   ├── modules/
│   │   ├── eks/                 # Custom EKS module
│   │   └── vpc/                 # Custom VPC module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf               
│
├── kubernetes/
│   ├── argocd
│   |   ├── app-of-apps.yml
│   |   ├── argocd-ingress.yml
│   |   └── applications/
│   │       ├── ad-app.yml
│   │       └── product-catalog-app.yml
|   |       └── recommendation-app.yml        
│   ├── productcatalog/
│   │   ├── deploy.yml
│   │   └── svc.yml
│   ├── recommendation/
│   │   ├── deploy.yml
│   │   └── svc.yml
│   ├── adservice/
│   │   ├── deploy.yml
│   │   └── svc.yml
│   └── frontendproxy
│       ├── deploy.yml
│       ├── svc.yml
│       └── frontendproxy-ingress.yml
│
├── .github/
│   └── workflows/
│       ├── ci-product-catalog.yml
│       ├── ci-recommendation.yml
│       └── ci-ad-service.yml
│
├── README.md                    # This file
├── ORIGINAL_README.md           # Original OpenTelemetry demo docs
└── LICENSE                      # Apache-2.0 License
```

## Infrastructure Details

### AWS Architecture Components

**Network Architecture**:
- **VPC**: Custom VPC with CIDR block
- **Subnets**: 4 subnets across 2 availability zones (us-east-1a, us-east-1b)
  - 2 Public subnets (for NAT Gateways and ALB)
  - 2 Private subnets (for EKS nodes)
- **NAT Gateways**: 2 NAT Gateways for high availability
- **Internet Gateway**: For public internet access

**EKS Cluster Configuration**:
- **Node Type**: EC2 t3.medium instances
- **Node Group**: Managed Node Group in private subnets
- **Kubernetes Version**: 1.31 (avoid extended support versions for cost optimization)
- **Security**: Private API endpoint with controlled access

**DNS & Certificate Management**:
- **Domain**: vishukumarpatel.com
- **DNS Records**:
  - `www.vishukumarpatel.com` - Application frontend
  - `api.vishukumarpatel.com` - (For testing) Application frontend
  - `argocd.vishukumarpatel.com` - ArgoCD dashboard
- **TLS Certificate**: Wildcard certificate `*.vishukumarpatel.com` from ACM

**Load Balancing**:
- **AWS ALB**: Application Load Balancer with TLS termination
- **Target Type**: IP-based targeting for direct pod communication
- **Health Checks**: Configured for HTTP/HTTPS endpoints

### Terraform Implementation

**Remote State Management**:
```hcl
# Backend configuration
backend "s3" {
  bucket         = "devops-terraform-otel-eks-state-s3-bucket"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-eks-state-locks"
  encrypt        = true
}
```

**Custom Modules**:
- **VPC Module**: Reusable VPC with configurable subnets, NAT, IGW
- **EKS Module**: EKS cluster with managed node groups and IAM roles

## CI/CD Pipeline

### Pipeline Stages

This explanation is for product-catalog microservice, which is golang based, checkout .github/ repo under root directory of this project, for more information regarding CI/CD pipeline setup. The CI/CD pipeline (GitHub Actions) consists of 4 main stages:

#### 1. Build Stage
- Checkout source code
- Setup Go 1.22 environment
- Download dependencies (`go mod download`)
- Compile application binary
- Run unit tests (`go test ./...`)

#### 2. Code Quality Stage
- Run `golangci-lint` for static code analysis
- Check for:
  - Unused variables and imports
  - Code formatting issues
  - Potential bugs and code smells
  - Best practice violations

#### 3. Docker Build & Push Stage
- Build multi-stage Docker image
- Tag with unique identifier (`github.run_id`)
- Push to DockerHub repository
- Image naming: `<username>/devops-otel-product-catalog:<run_id>`

#### 4. GitOps Update Stage
- Update Kubernetes deployment manifest
- Replace image tag with new build ID
- Commit and push changes to repository
- ArgoCD detects changes and syncs automatically

### Pipeline Triggers

```yml
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
    paths:
      - 'src/product-catalog/**'
      - '.github/workflows/ci-product-catalog.yml'
```

### GitOps Workflow with ArgoCD

1. **Developer** commits code changes to GitHub
2. **GitHub Actions** pipeline executes automatically
3. **Pipeline** builds, tests, and pushes Docker image
4. **Pipeline** updates Kubernetes manifest with new image tag
5. **ArgoCD** detects manifest changes in Git repository
6. **ArgoCD** automatically syncs and deploys to EKS cluster
7. **Kubernetes** performs rolling update with zero downtime

## Prerequisites

### To Run Application Locally

- **Docker**: Latest version
- **Docker Compose**: v2.0.0 or higher
- **System Requirements**:
  - 6 GB RAM minimum
  - 14 GB disk space
- **Make**: (Optional) for build automation

### For DevOps Implementation

- **AWS Account**: With appropriate permissions
- **AWS CLI**: Configured with credentials
- **eksctl**: For EKS cluster management
- **kubectl**: Kubernetes command-line tool
- **Terraform**: v1.x or higher
- **GitHub Account**: For CI/CD pipelines
- **DockerHub Account**: For container registry
- **Domain Name**: For production deployment (optional)

### IAM Permissions Required

Ensure your AWS user/role has the following policies:
- `AmazonEKSClusterPolicy`
- `AmazonEKSServicePolicy`
- `AmazonEC2ContainerRegistryReadOnly` ⚠️ *Critical for EKS Nodegroup*
- `AmazonEKS_CNI_Policy` ⚠️ *Critical for EKS Nodegroup*
- `AmazonEKSWorkerNodePolicy` ⚠️ *Critical for EKS Nodegroup*
- `AmazonVPCFullAccess`
- Custom policies for S3, DynamoDB (for Terraform state)

## Getting Started

### Step 1: Clone the Repository

```bash
git clone https://github.com/VishuPatel-27/ultimate-devops-project.git
cd ultimate-devops-project
```

### Step 2: Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and Region
```

### Step 3: Initialize Terraform

```bash
cd infra/
cd backend/
terraform init
terraform plan
terraform apply
cd .. (go back to infra directory)
terraform init
terraform plan
terraform apply
```

### Step 4: Configure kubectl

```bash
aws eks update-kubeconfig --name <cluster-name> --region us-east-1
kubectl get nodes
```

### Step 5: Install ArgoCD

> **Note**: Before installing ArgoCD on your cluster, go through this installation guide, [official docs](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/) ,for safer side deployment.

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yml

# Apply custom ingress configuration
kubectl apply -f kubernetes/ingress/argocd-ingress.yml
```

### Step 6: Install AWS ALB Ingress Controller

> **Note**: Before installing AWS ALB Ingress Controller on your cluster, go through this installation guide, [official docs](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v1.1/) ,for safer side deployment.

```bash
# Create IAM service account for ALB controller
eksctl create iamserviceaccount \
  --cluster=<cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# Install ALB controller using Helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Step 7: Configure GitHub Secrets

Add the following secrets to your GitHub repository:

- `DOCKER_TOKEN`: DockerHub access token
- `ULTIMATE_DEVOPS_PROJECT_GITHUB_TOKEN`: GitHub PAT with repo access
- `GIT_USER_EMAIL`: Your git email

Add variables:
- `DOCKER_USERNAME`: Your DockerHub username
- `GIT_USER_NAME`: Your git username

### Step 8: Deploy Application

```bash
# Apply Kubernetes manifests
kubectl apply -f kubernetes/

# Or use ArgoCD UI to sync applications
```

## Deployment Process

### Manual Deployment

> **Note**: For testing you could also make any dummy comment or change in codebase and commit it to Github repo which would trigger CI/CD pipeline and ArgoCD deploys the changes.

```bash
# Build Docker image locally
cd src/product-catalog
docker build -t <username>/product-catalog:<tag> .
docker push <username>/product-catalog:<tag>

# Deploy to Kubernetes
kubectl apply -f kubernetes/productcatalog/deploy.yml
```

### Automated Deployment (GitOps)

1. Make code changes in `src/product-catalog/`
2. Commit and push to `main` branch
3. GitHub Actions pipeline triggers automatically
4. Pipeline builds, tests, and pushes Docker image
5. Pipeline updates Kubernetes manifest
6. ArgoCD detects changes and syncs to cluster

### Accessing Applications
> **Note**: THESE ENDPOINTS ARE NOT WORKING, I HAVE DELETED THE INFRA.

- **Application**: https://www.vishukumarpatel.com
- **API**: https://api.vishukumarpatel.com
- **ArgoCD Dashboard**: https://argocd.vishukumarpatel.com

## Challenges & Solutions

### Challenge 1: Pod Scheduling Failure

**Error**:
```
FailedScheduling: 0/2 nodes are available: 2 Too many pods. 
preemption: 0/2 nodes are available: 2 No preemption victims found for incoming pod.
```

**Root Cause**: EKS nodes running out of available pod slots. Each instance type has a maximum pod limit based on ENI and IP constraints.

**Solution**: 
- Analyzed pod distribution across nodes
- Increased node count in the node group

### Challenge 2: IAM Service Account Issues

**Error**:
```
AccessDenied: AssumeRoleWithWebIdentity
```

**Root Cause**: IAM service account for AWS ALB Ingress Controller was not created properly or had stale configuration.

**Solution**:
```bash
# Delete existing service account
eksctl delete iamserviceaccount --cluster=<cluster-name> --namespace=kube-system --name=aws-load-balancer-controller

# Recreate with proper OIDC trust relationship
eksctl create iamserviceaccount \
  --cluster=<cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name=AmazonEKSLoadBalancerControllerRole
  --override-existing-serviceaccounts \
  --approve
```

### Challenge 3: ArgoCD Health Check Failures

**Error**: ALB health checks returning `307 Redirect`, marking targets as unhealthy.

**Root Cause**: 
- Health check was hitting the root path `/` which redirects to HTTPS
- ArgoCD expects HTTPS health checks on `/healthz` endpoint

**Solution**: Updated ArgoCD Ingress annotations ([argocd-ingress.yml](https://github.com/VishuPatel-27/ultimate-devops-project/blob/main/kubernetes/argocd/argocd-ingress.yaml)):
```yml
annotations:
  alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
  alb.ingress.kubernetes.io/healthcheck-path: /healthz
  alb.ingress.kubernetes.io/backend-protocol: HTTPS
```

### Challenge 4: Missing IAM Permissions

**Error**: Terraform apply failed during EKS node group creation.

**Root Cause**: Accidentally removed `AmazonEC2ContainerRegistryReadOnly` policy from IAM role. This policy is critical for nodes to pull container images from ECR (even when using DockerHub, for AWS CNI images).

**Solution**:
- Identified missing policy through CloudTrail and terraform logs
- Re-attached the policy to the node IAM role:
```bash
aws iam attach-role-policy \
  --role-name <eks-node-role> \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

## Cost Estimation

**Total Project Cost**: ~$5-10 CAD [It may vary based on your config and duration]

### Cost Breakdown:

| Service | Estimated Cost | Notes |
|---------|---------------|-------|
| EKS Cluster Control Plane | ~$3.60 | $0.10/hour × ~36 hours |
| EC2 Instances (t3.medium × 3) | ~$3-5 | Depends on runtime |
| NAT Gateway | ~$2-3 | Data transfer costs |
| ALB | ~$1 | Minimal traffic |
| Route53 | ~$0.50 | Hosted zone |
| S3 (Terraform State) | <$0.10 | Minimal storage |
| ACM Certificate | Free | |

**Cost Optimization Tips**:
- Avoid Kubernetes extended support versions (e.g., 1.30+) - adds significant cost
- Use standard support versions (e.g., 1.31)
- Destroy resources when not in use: `terraform destroy`
- Use `t3.medium` instead of larger instances for learning projects
- Consider AWS Free Tier credits if available

> **Note**: Costs may vary based on region, runtime duration, and data transfer. This implementation was run twice for testing, accumulating the mentioned costs.

## Key Learnings

### Technical Skills Gained

1. **Infrastructure as Code**: 
   - Terraform custom module development
   - Remote state management with S3 and DynamoDB
   - AWS resource provisioning and management

2. **Container Orchestration**:
   - Kubernetes deployment strategies
   - Pod resource management and scheduling
   - Ingress configuration

3. **CI/CD Best Practices**:
   - GitHub Actions workflow design
   - Multi-stage Docker builds
   - Automated testing and deployment

4. **GitOps Methodology**:
   - Declrative app-of-apps approach
   - ArgoCD application configuration
   - Declarative deployment management
   - Automated synchronization

5. **Cloud Security**:
   - IAM roles and service accounts
   - TLS/SSL certificate management
   - Network security with VPCs and security groups

6. **Troubleshooting**:
   - Debugging Kubernetes scheduling issues
   - Resolving IAM permission problems
   - Fixing health check configurations

### Best Practices Implemented

- Multi-stage Docker builds for smaller images
- Non-root container users for security
- Immutable infrastructure with IaC
- GitOps for deployment automation
- Separation of concerns (CI vs CD)
- Proper secrets management
- High availability across AZs
- TLS encryption for all endpoints## 

## Acknowledgments

- **OpenTelemetry Community**: For the excellent demo application
  - Original repository: https://github.com/open-telemetry/opentelemetry-demo
  - Licensed under Apache-2.0

- **AWS**: For comprehensive cloud services and documentation

- **ArgoCD & CNCF**: For GitOps tooling and Kubernetes ecosystem

## License

This DevOps implementation maintains the original Apache-2.0 license from the OpenTelemetry Demo project.

### Original Project
- **Project**: OpenTelemetry Demo
- **License**: Apache License 2.0
- **Copyright**: OpenTelemetry Authors

### This Implementation
- **Author**: Vishu Patel ([@VishuPatel-27](https://github.com/VishuPatel-27))
- **License**: Apache License 2.0
- **Modifications**: Added CI/CD pipelines, infrastructure code, and deployment configurations

See [LICENSE](LICENSE) file for full license text.

---

## Contact

**Vishu Patel**
- GitHub: [@VishuPatel-27](https://github.com/VishuPatel-27)
- LinkedIn: [LinkedIn Profile](https://www.linkedin.com/in/vishu-patel/)

---

**Note**: This project was created as a portfolio piece to demonstrate hands-on DevOps skills and practical implementation experience. For the original OpenTelemetry Demo documentation, please refer to [ORIGINAL_README.md](ORIGINAL_README.md).

**⭐ If you find this project helpful, please consider giving it a star!**
