variable "subnets_raw" {
  type    = string
  default = "['subnet-123456', 'subnet-789012']"
}

locals {
  subnets = jsondecode(
    replace(var.subnets_raw, "'", "\"")
  )
}

output "subnet_name" {
  value = local.subnets
}