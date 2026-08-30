# ---------------------------------------------------------------------------
# RDS PostgreSQL for Backstage
# Private, cluster-internal. Reachable only from within the VPC (EKS pods).
# Ephemeral with the cluster lifecycle — no idle cost between sessions.
# ---------------------------------------------------------------------------

# Subnet group across the private subnets
resource "aws_db_subnet_group" "taskflow_backstage" {
  name = "taskflow-backstage-db-subnet-group"
  subnet_ids = [
    aws_subnet.taskflow_private_subnet_1.id,
    aws_subnet.taskflow_private_subnet_2.id
  ]

  tags = {
    Name = "taskflow-backstage-db-subnet-group"
  }
}

# Security group: allow PostgreSQL (5432) only from inside the VPC
resource "aws_security_group" "taskflow_backstage_rds" {
  name        = "taskflow-backstage-rds-sg"
  description = "Allow PostgreSQL from within the VPC only"
  vpc_id      = aws_vpc.taskflow_vpc.id

  ingress {
    description = "PostgreSQL from within the VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.taskflow_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "taskflow-backstage-rds-sg"
  }
}

# PostgreSQL instance — production-grade, private, cost-conscious sizing
resource "aws_db_instance" "taskflow_backstage" {
  identifier     = "taskflow-backstage"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "backstage"
  username = var.backstage_db_username
  password = var.backstage_db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.taskflow_backstage.name
  vpc_security_group_ids = [aws_security_group.taskflow_backstage_rds.id]

  publicly_accessible = false
  multi_az            = false
  skip_final_snapshot = true

  tags = {
    Name = "taskflow-backstage"
  }
}