output "project" {
  value = lookup(var.project_config, var.project_id)
}

output "region" {
  value = lookup(var.project_config, var.region)
}