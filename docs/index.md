# TaskFlow Infrastructure

This is the foundational infrastructure layer for the TaskFlow platform, defined entirely in Terraform.

## What this provisions

- **Networking** — an Amazon VPC with the subnets, routing, and gateways the cluster needs.
- **Compute** — an Amazon EKS cluster that hosts every TaskFlow workload.
- **Supporting services** — Amazon ECR for images and an S3 + DynamoDB backend for remote Terraform state with locking.

## How it fits

`taskflow-infra` sits at the base of the stack. Once the cluster is up, application manifests from `taskflow-app` are delivered onto it through the GitOps config in `taskflow-gitops`.

## Where to go next

- [Architecture](architecture.md) — the infrastructure design and key operational decisions.