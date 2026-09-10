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
# Branch: develop
# ---------------------------------------------------------

# Branch nova (não é a default do project) — sem replace_existing.
# Fork da production: nasce com role/database/dados copiados por
# copy-on-write no momento da criação.
# ttl: branch descartável, expira sozinha após a duração (7 dias).
# ttl / expire_time / no_expiry são mutuamente exclusivos.
resource "databricks_postgres_branch" "develop" {
  branch_id = "develop"

  parent = databricks_postgres_project.this.name

  spec = {
    ttl           = "604800s" # 7 dias
    source_branch = databricks_postgres_branch.production.name
  }

  depends_on = [
    databricks_postgres_database.app
  ]
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

# ---------------------------------------------------------
# Endpoint: develop
# ---------------------------------------------------------

# O branch develop também provisiona um endpoint default "primary" —
# replace_existing adota esse endpoint em vez de criar um segundo.
resource "databricks_postgres_endpoint" "develop_primary" {
  endpoint_id = "primary"

  parent = databricks_postgres_branch.develop.name

  spec = {
    endpoint_type            = "ENDPOINT_TYPE_READ_WRITE"
    autoscaling_limit_min_cu = 0.5
    autoscaling_limit_max_cu = 0.5
    suspend_timeout_duration = "60s"
  }

  replace_existing = true
}

# ---------------------------------------------------------
# ROLES de grupos
# ---------------------------------------------------------

# Pré-requisitos:
# - O grupo precisa existir no Databricks (account/workspace) ANTES do apply.
#   Aqui só declaramos a role Postgres que aponta pra ele.
# - Roles no mesmo branch não podem ser criadas em paralelo — encadear
#   sempre com depends_on na role anterior do branch.
# - Grupos logam via OAuth (LAKEBASE_OAUTH_V1), não têm senha.

# Exemplo 1: grupo com acesso direto ao banco (login via OAuth)
resource "databricks_postgres_role" "analytics_group" {
  role_id = "analytics"

  parent = databricks_postgres_branch.production.name

  spec = {
    identity_type = "GROUP"             # role backed por um grupo Databricks
    postgres_role = "analytics-team"    # NOME EXATO do grupo no Databricks
    auth_method   = "LAKEBASE_OAUTH_V1" # membros logam via OAuth

    attributes = {
      createdb   = false
      createrole = false
      bypassrls  = false
    }
  }

  depends_on = [
    databricks_postgres_role.app
  ]
}

# Exemplo 2: role NO_LOGIN que só agrega privilégios (alvo de GRANT)
resource "databricks_postgres_role" "readers" {
  role_id = "readers"

  parent = databricks_postgres_branch.production.name

  spec = {
    postgres_role = "readers"
    auth_method   = "NO_LOGIN" # não loga; só carrega permissões
  }

  depends_on = [
    databricks_postgres_role.analytics_group
  ]
}

# Exemplo 3: grupo que loga via OAuth e (via SQL) vira membro de "readers"
resource "databricks_postgres_role" "data_team_group" {
  role_id = "data-team"

  parent = databricks_postgres_branch.production.name

  spec = {
    identity_type = "GROUP"
    postgres_role = "data-team" # grupo Databricks
    auth_method   = "LAKEBASE_OAUTH_V1"
  }

  # o GRANT readers TO "data-team" é feito via SQL no Postgres;
  # o provider gerencia a existência da role, não o grant entre roles.
  depends_on = [
    databricks_postgres_role.readers
  ]
}

# Exemplo 4: grupo com privilégio máximo exposto ao cliente
resource "databricks_postgres_role" "admins_group" {
  role_id = "admins"

  parent = databricks_postgres_branch.production.name

  spec = {
    identity_type    = "GROUP"
    postgres_role    = "platform-admins" # grupo Databricks
    auth_method      = "LAKEBASE_OAUTH_V1"
    membership_roles = ["DATABRICKS_SUPERUSER"]
    # membership_roles SOBRESCREVE as memberships a cada apply (não faz merge)
  }

  depends_on = [
    databricks_postgres_role.data_team_group
  ]
}