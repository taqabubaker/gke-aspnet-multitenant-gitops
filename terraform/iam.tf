# GSA for Tenant A
resource "google_service_account" "tenant_a_gsa" {
  account_id   = "tenant-a-app-sa"
  display_name = "Service Account for Tenant A Application"
}

# GSA for Tenant B
resource "google_service_account" "tenant_b_gsa" {
  account_id   = "tenant-b-app-sa"
  display_name = "Service Account for Tenant B Application"
}

# IAM Roles for Tenant A GSA
resource "google_project_iam_member" "tenant_a_sql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.tenant_a_gsa.email}"
}

resource "google_secret_manager_secret_iam_member" "tenant_a_secret_accessor" {
  secret_id = google_secret_manager_secret.tenant_a_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.tenant_a_gsa.email}"
}

# IAM Roles for Tenant B GSA
resource "google_project_iam_member" "tenant_b_sql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.tenant_b_gsa.email}"
}

resource "google_secret_manager_secret_iam_member" "tenant_b_secret_accessor" {
  secret_id = google_secret_manager_secret.tenant_b_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.tenant_b_gsa.email}"
}

# Workload Identity Binding for Tenant A
# Maps KSA 'app-sa' in namespace 'tenant-a' to GSA 'tenant-a-app-sa'
resource "google_service_account_iam_member" "tenant_a_wi" {
  service_account_id = google_service_account.tenant_a_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[tenant-a/app-sa]"
}

# Workload Identity Binding for Tenant B
# Maps KSA 'app-sa' in namespace 'tenant-b' to GSA 'tenant-b-app-sa'
resource "google_service_account_iam_member" "tenant_b_wi" {
  service_account_id = google_service_account.tenant_b_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[tenant-b/app-sa]"
}
