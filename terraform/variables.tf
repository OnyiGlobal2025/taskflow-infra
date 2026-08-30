variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "backstage_db_username" {
  description = "Master username for the Backstage RDS PostgreSQL instance"
  type        = string
  default     = "backstage_admin"
}

variable "backstage_db_password" {
  description = "Master password for the Backstage RDS PostgreSQL instance (supplied at apply time, never committed)"
  type        = string
  sensitive   = true
}