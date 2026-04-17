output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "tenant_a_db_connection" {
  value = google_sql_database_instance.tenant_a_db.connection_name
}

output "tenant_b_db_connection" {
  value = google_sql_database_instance.tenant_b_db.connection_name
}

output "tenant_a_gsa_email" {
  value = google_service_account.tenant_a_gsa.email
}

output "tenant_b_gsa_email" {
  value = google_service_account.tenant_b_gsa.email
}
