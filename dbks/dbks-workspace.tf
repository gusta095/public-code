provider "databricks" {
  host = "https://sua-url-do-control-plane"
  token = "seu-token-aqui"
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

resource "databricks_mws_workspaces" "meu_workspace" {
  workspace_name = "meu-workspace"
  aws_region   = "us-west-2"
  credentials_id = aws_iam_role.databricks_role.id
  
  storage_configuration = {
    bucket = "seu-bucket-s3"
  }
  
  network_configuration = {
    vpc_id = "sua-vpc-id"
    subnet_ids = ["subnet-id-1", "subnet-id-2"]
  }

  # Você também pode configurar o PrivateLink ou outras opções conforme necessário
}
