# Cluster All-Purpose. O policy_id cria a dependência: a policy é criada antes.
resource "databricks_cluster" "all_purpose" {
  cluster_name = "compute-all-purpose-dev"
  policy_id    = databricks_cluster_policy.all_purpose.id

  spark_version       = "15.4.x-scala2.12"
  node_type_id        = "i3.xlarge"
  driver_node_type_id = "i3.xlarge"

  data_security_mode      = "USER_ISOLATION"
  num_workers             = 1
  autotermination_minutes = 30
}
