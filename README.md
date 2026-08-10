# TaskFlow — Infrastructure (Terraform)

Terraform configuration that provisions the AWS infrastructure for the TaskFlow platform: EKS cluster, VPC, IAM roles (IRSA), ECR, OIDC providers, and remote state (S3 + DynamoDB).

📖 **Full project documentation:** [taskflow-gitops](https://github.com/OnyiGlobal2025/taskflow-gitops)

---

## Internal Developer Portal (Backstage / TechDocs)

Beyond its Project 1 role, this repo is registered in the TaskFlow Backstage portal. Its documentation is published to TechDocs; source lives in [`docs/`](./docs), with the infrastructure design in [`docs/architecture.md`](./docs/architecture.md).

- AWS account: `713923090919`
- Region: `us-east-1`
- Default branch: `main`