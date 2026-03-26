# DevOps Pipeline — Spring Boot on AWS

A production-ready DevOps pipeline for a Spring Boot application, featuring:
Jenkins CI/CD • Docker containerisation • Terraform IaC on AWS • Prometheus/Grafana monitoring

---

## Architecture

```
GitHub → Jenkins → ECR → EC2 (AWS)
                           ↑
                    Terraform provisions:
                    VPC + Subnets + SG
                    EC2 (t3.micro)
                    S3 (artifact storage)
```

---

## Project Structure

```
devops-pipeline/
├── app/                        # Spring Boot application
│   ├── src/
│   ├── build.gradle
│   └── config/checkstyle/
│   ├── Dockerfile              # Multi-stage build
│   └── Jenkinsfile             # CI/CD pipeline
├── terraform/
│   ├── main.tf                 # Root module
│   ├── variables.tf
│   ├── outputs.tf
│   ├── modules/
│   │   ├── networking/         # VPC, subnets, SG
│   │   ├── ec2/                # Instance, IAM, EIP
│   │   └── storage/            # S3 bucket
│   └── environments/dev/
│       └── terraform.tfvars
└── monitoring/
    ├── prometheus/
    │   └── prometheus.yml
    └── grafana/
        └── provisioning/       # Auto-configured datasource + dashboard
```

---

## Quick Start

### 1. Prerequisites
- Docker & Docker Compose
- Terraform >= 1.6
- AWS CLI configured (`aws configure`)
- Jenkins with plugins: Pipeline, SSH Agent, Docker Pipeline, HTML Publisher

### 2. Run Locally with Docker Compose

```bash
cd docker
docker-compose up -d

# App:        http://localhost:8080
# Prometheus: http://localhost:9090
# Grafana:    http://localhost:3000  (admin / admin123)
```

### 3. Provision AWS Infrastructure

```bash
cd terraform

# First time: create S3 + DynamoDB for remote state
aws s3api create-bucket --bucket devops-demo-tfstate --region us-east-1
aws dynamodb create-table \
  --table-name devops-demo-tfstate-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Deploy
cp environments/dev/terraform.tfvars .
terraform init
terraform plan
terraform apply
```

### 4. Jenkins Setup

**Required Credentials** (Manage Jenkins → Credentials):

| ID                      | Type              | Description                         |
|-------------------------|-------------------|-------------------------------------|
| `DOCKERHUB_CREDENTIALS` | Username/Password | Docker Hub login                    |
| `EC2_HOST`              | Secret text       | EC2 public IP from Terraform output |
| `EC2_SSH_KEY`           | SSH private key   | PEM key for EC2 access              |

**Create Pipeline:**
1. New Item → Pipeline
2. Pipeline → Definition: "Pipeline script from SCM"
3. SCM: Git → your repo URL
4. Script Path: `Jenkinsfile`

## Monitoring

Grafana comes pre-provisioned with a **Spring Boot Metrics** dashboard showing:
- HTTP request rate
- JVM heap usage
- HTTP error rate
- p99 response latency

The Spring Boot app exposes Prometheus metrics at `/actuator/prometheus` via the
`micrometer-registry-prometheus` dependency.

---

## Key Design Decisions

- **Multi-stage Docker build** — final image is JRE-only (~200 MB vs ~500 MB)
- **Non-root container user** — security hardening
- **Terraform remote state** — S3 backend with DynamoDB locking prevents conflicts
- **Elastic IP** — stable public IP survives instance restarts
- **IAM role on EC2** — no static AWS credentials; scoped S3 access only
- **Grafana auto-provisioning** — datasource + dashboard configured via files, no manual setup
