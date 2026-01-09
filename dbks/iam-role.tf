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
