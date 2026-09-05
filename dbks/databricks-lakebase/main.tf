# ---------------------------------------------------------
# Lakebase Project
# ---------------------------------------------------------

resource "databricks_postgres_project" "this" {
  project_id = var.project_id

  spec = {
    pg_version   = 17
    display_name = var.project_name

    default_endpoint_settings = {
      autoscaling_limit_min_cu = 0.5
      autoscaling_limit_max_cu = 0.5
      suspend_timeout_duration = "60s"
    }
  }
}

# ---------------------------------------------------------
# Branch
# ---------------------------------------------------------

# O project já provisiona automaticamente um branch default "production"
# ao ser criado — replace_existing adota esse branch em vez de criar um
# segundo (evita duplicidade de branch/endpoint e custo dobrado).
resource "databricks_postgres_branch" "production" {
  branch_id = "production"

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

  parent = databricks_postgres_branch.production.name

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

  parent = databricks_postgres_branch.production.name

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

# O branch já provisiona automaticamente um endpoint default "primary"
# ao ser criado — replace_existing adota esse endpoint em vez de criar
# um segundo (o backend só permite um endpoint read_write por branch).
resource "databricks_postgres_endpoint" "primary" {
  endpoint_id = "primary"

  parent = databricks_postgres_branch.production.name

  spec = {
    endpoint_type            = "ENDPOINT_TYPE_READ_WRITE"
    autoscaling_limit_min_cu = 0.5
    autoscaling_limit_max_cu = 0.5
    suspend_timeout_duration = "60s"
  }

  replace_existing = true

  depends_on = [
    databricks_postgres_database.app
  ]
}