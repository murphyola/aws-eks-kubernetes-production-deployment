# AWS EKS Kubernetes Production Deployment

Production-ready Amazon EKS infrastructure built with Terraform, including a custom VPC, managed node groups, EKS managed add-ons, and a Kubernetes application exposed through an AWS Elastic Load Balancer.

---

## Project Overview

This project demonstrates how to provision and operate a production-style Kubernetes platform on AWS using Infrastructure as Code and Kubernetes best practices.

The infrastructure includes:

* Custom VPC with public and private subnets
* Internet Gateway and NAT Gateway
* Amazon EKS cluster (Kubernetes v1.33)
* Managed node groups
* EKS managed add-ons
* Kubernetes Deployment and LoadBalancer Service
* Public access through an AWS Elastic Load Balancer

---

## Architecture

```text
                                                Internet
                                    │
                                    ▼
                      AWS Elastic Load Balancer (ELB)
                                    │
                                    ▼
                        Kubernetes LoadBalancer Service
                                    │
                                    ▼
                           NGINX Deployment (Pod)
                                    │
        ┌───────────────────────────┴───────────────────────────┐
        │                                                       │
        ▼                                                       ▼
+----------------------+                              +----------------------+
| EKS Worker Node 1    |                              | EKS Worker Node 2    |
| (t3.medium)          |                              | (t3.medium)          |
| kube-proxy           |                              | kube-proxy           |
| aws-node (VPC CNI)   |                              | aws-node (VPC CNI)   |
| Pod Identity Agent   |                              | Pod Identity Agent   |
+----------------------+                              +----------------------+
        │                                                       │
        └───────────────────────────┬───────────────────────────┘
                                    │
                                    ▼
                    Amazon EKS Control Plane (Managed)
                     • API Server
                     • Scheduler
                     • Controller Manager
                     • CoreDNS
                                    │
                                    ▼
                          Private Subnets (3 AZs)
                                    │
                                    ▼
                            Amazon VPC (10.0.0.0/16)
                                    │
                 ┌──────────────────┴──────────────────┐
                 ▼                                     ▼
        Internet Gateway                       NAT Gateway
                 │                                     │
          Public Subnets                     Private Subnets
---

## Technologies Used

| Category                | Technology             |
| ----------------------- | ---------------------- |
| Cloud                   | AWS                    |
| IaC                     | Terraform              |
| Container Orchestration | Kubernetes             |
| Managed Kubernetes      | Amazon EKS             |
| Networking              | VPC, Subnets, NAT, IGW |
| CI/CD Ready             | GitHub Actions         |
| Container Runtime       | containerd             |
| Web Server              | NGINX                  |

---

## Repository Structure

```text
aws-eks-kubernetes-production-deployment/
├── terraform/
├── kubernetes/
├── screenshots/
├── README.md
└── .gitignore
```

---

## Infrastructure Components

### Networking

* 1 VPC
* 3 Public Subnets
* 3 Private Subnets
* 1 Internet Gateway
* 1 NAT Gateway
* Route Tables and Associations

### EKS

* Kubernetes 1.33
* Public API Endpoint
* OIDC Provider
* KMS Encryption
* Managed Node Group (t3.medium)

### Managed Add-ons

* Amazon VPC CNI
* CoreDNS
* kube-proxy
* EKS Pod Identity Agent

---

## Deployment Steps

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Validate Configuration

```bash
terraform validate
terraform plan
```

### 3. Deploy Infrastructure

```bash
terraform apply
```

---

## Configure kubectl

```bash
aws eks update-kubeconfig \
  --region eu-north-1 \
  --name portfolio-eks-cluster
```

---

## Verify the Cluster

### Check Nodes

```bash
kubectl get nodes
```

Expected:

```text
STATUS: Ready
```

### Check System Pods

```bash
kubectl get pods -n kube-system
```

Expected pods:

* aws-node
* coredns
* kube-proxy
* eks-pod-identity-agent

---

## Deploy the Application

### Create Namespace

```bash
kubectl apply -f kubernetes/namespace.yaml
```

### Deploy NGINX

```bash
kubectl apply -f kubernetes/deployment.yaml
```

### Expose via LoadBalancer

```bash
kubectl apply -f kubernetes/service.yaml
```

### Verify

```bash
kubectl get all -n demo
```

---

## Public Access

The application is exposed through an AWS Elastic Load Balancer.

Example:

```text
http://<elb-dns-name>
```

Verification:

```bash
curl http://<elb-dns-name>
```

Expected response:

```html
Welcome to nginx!
```

---

## Key Troubleshooting Lesson

During the initial deployment, worker nodes failed with:

```text
NodeCreationFailure: Unhealthy nodes in the kubernetes cluster
```

The issue was resolved by deploying the **VPC CNI add-on before the managed node group**:

```hcl
addons = {
  vpc-cni = {
    before_compute = true
  }
}
```

This is an important EKS networking dependency and a valuable production troubleshooting experience.

---

## Skills Demonstrated

* Terraform module design
* AWS VPC architecture
* Amazon EKS provisioning
* IAM and OIDC integration
* Kubernetes workload deployment
* Service exposure through AWS Load Balancers
* EKS networking troubleshooting
* Infrastructure validation and verification

---

## Future Improvements

* GitHub Actions CI/CD
* Amazon ECR integration
* AWS Load Balancer Controller
* Ingress with HTTPS
* Prometheus & Grafana monitoring
* Horizontal Pod Autoscaler
* GitOps with Argo CD

---

## Cleanup

To avoid AWS charges:

```bash
cd terraform
terraform destroy
```

---

## Author

**Maruf Salaudeen**
Cloud & DevOps Engineer | AWS | Terraform | Kubernetes | CI/CD

