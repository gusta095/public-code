provider "aws" {
  region = "us-west-2" # Ajuste para sua região
}

resource "aws_iam_role" "databricks_role" {
  name = "databricks-access-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "databricks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "databricks_policy" {
  name        = "DatabricksAccessPolicy"
  description = "Política para Databricks acessar recursos necessários"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "databricks_role_attach" {
  role       = aws_iam_role.databricks_role.name
  policy_arn = aws_iam_policy.databricks_policy.arn
}

# Security Group para permitir tráfego entre sua VPC e os endpoints
resource "aws_security_group" "vpce_sg" {
  name        = "databricks‐privatelink‐sg"
  description = "Permite tráfego entre a VPC e os endpoints Databricks"
  vpc_id      = var.vpc_id

  # Permissões mínimas (ajuste conforme sua política)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Comunicação interna entre recursos com o mesmo SG
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPC Endpoint para o Workspace/REST API (fronteira de PrivateLink)
resource "aws_vpc_endpoint" "databricks_workspace_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.vpce_sg.id]

  private_dns_enabled = true
}

# VPC Endpoint para o Relay de conectividade de cluster seguro
resource "aws_vpc_endpoint" "databricks_scc_relay" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.vpce_sg.id]

  private_dns_enabled = true
}

variable "vpc_id" {
  description = "ID da VPC onde os VPC endpoints serão criados"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs das subnets privadas onde os endpoints serão provisionados"
}

variable "vpc_cidr_block" {
  description = "CIDR da VPC para regras de SG"
}
