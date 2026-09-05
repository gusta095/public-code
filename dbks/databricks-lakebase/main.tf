terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.128"
    }
  }
}

provider "databricks" {
  host = var.databricks_host

  # Recomendo OAuth/M2M em ambiente real.
  # Para laboratório, você pode configurar
  # DATABRICKS_HOST / DATABRICKS_TOKEN.
}

# ---------------------------------------------------------
# Lakebase Project
# ---------------------------------------------------------

resource "databricks_postgres_project" "this" {
  project_id = var.project_id

  spec = {
    pg_version   = 17
    display_name = var.project_name

    default_endpoint_settings = {
      autoscaling_limit_min_cu = 1.0
      autoscaling_limit_max_cu = 4.0
    }
  }
}

# ---------------------------------------------------------
# Branch
# ---------------------------------------------------------

resource "databricks_postgres_branch" "main" {
  branch_id = "main"

  parent = databricks_postgres_project.this.name

  spec = {
    no_expiry = true
  }

  replace_existing = true
}

# ---------------------------------------------------------
# Role
# ---------------------------------------------------------

resource "databricks_postgres_role" "app" {
  role_id = "app"

  parent = databricks_postgres_branch.main.name

  spec = {
    postgres_role = "app"

    auth_method = "PG_PASSWORD_SCRAM_SHA_256"

    attributes = {
      createdb   = false
      createrole = false
      bypassrls  = false
    }
  }
}

# ---------------------------------------------------------
# Database
# ---------------------------------------------------------

resource "databricks_postgres_database" "app" {
  database_id = "app"

  parent = databricks_postgres_branch.main.name

  spec = {
    postgres_database = "app"
    role              = databricks_postgres_role.app.name
  }

  depends_on = [
    databricks_postgres_role.app
  ]
}

# ---------------------------------------------------------
# Endpoint
# ---------------------------------------------------------

resource "databricks_postgres_endpoint" "main" {
  endpoint_id = "main"

  parent = databricks_postgres_branch.main.name

  spec = {
    autoscaling_limit_min_cu = 1.0
    autoscaling_limit_max_cu = 4.0
  }

  depends_on = [
    databricks_postgres_database.app
  ]
}