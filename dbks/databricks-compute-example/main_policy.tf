# Policy: define as regras que o cluster precisa respeitar.
resource "databricks_cluster_policy" "all_purpose" {
  name = "policy-all-purpose-dev"

  definition = jsonencode({
    "cluster_type"            = { type = "fixed", value = "all-purpose" }
    "spark_version"           = { type = "fixed", value = "15.4.x-scala2.12" }
    "node_type_id"            = { type = "fixed", value = "i3.xlarge" }
    "driver_node_type_id"     = { type = "fixed", value = "i3.xlarge" }
    "data_security_mode"      = { type = "fixed", value = "USER_ISOLATION" }
    "num_workers"             = { type = "range", minValue = 1, maxValue = 4, defaultValue = 1 }
    "autotermination_minutes" = { type = "fixed", value = 30 }
  })
}
