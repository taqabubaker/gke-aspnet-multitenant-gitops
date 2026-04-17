provider "google" {
  project = var.project_id
  region  = var.region
}

# Get GKE cluster credentials
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Enable necessary APIs
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  enable_autopilot = true

  depends_on = [google_project_service.services]
}

# Cloud SQL Instance for Tenant A
resource "google_sql_database_instance" "tenant_a_db" {
  name             = "mssql-tenant-a"
  database_version = "SQLSERVER_2019_STANDARD"
  region           = var.region
  root_password    = var.tenant_a_db_password

  settings {
    tier = "db-custom-2-7680" # MSSQL requires at least 2 vCPUs and 3.75GB RAM per vCPU typically
  }

  deletion_protection = false
  depends_on          = [google_project_service.services]
}

# Cloud SQL Instance for Tenant B
resource "google_sql_database_instance" "tenant_b_db" {
  name             = "mssql-tenant-b"
  database_version = "SQLSERVER_2019_STANDARD"
  region           = var.region
  root_password    = var.tenant_b_db_password

  settings {
    tier = "db-custom-2-7680"
  }

  deletion_protection = false
  depends_on          = [google_project_service.services]
}

# Secret Manager Secret for Tenant A
resource "google_secret_manager_secret" "tenant_a_secret" {
  secret_id = "tenant-a-db-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.services]
}

resource "google_secret_manager_secret_version" "tenant_a_secret_version" {
  secret      = google_secret_manager_secret.tenant_a_secret.id
  secret_data = var.tenant_a_db_password
}

# Secret Manager Secret for Tenant B
resource "google_secret_manager_secret" "tenant_b_secret" {
  secret_id = "tenant-b-db-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.services]
}

resource "google_secret_manager_secret_version" "tenant_b_secret_version" {
  secret      = google_secret_manager_secret.tenant_b_secret.id
  secret_data = var.tenant_b_db_password
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "my_repo" {
  location      = var.region
  repository_id = var.artifact_registry_name
  description   = "Docker repository for GKE demo"
  format        = "DOCKER"

  depends_on = [google_project_service.services]
}

# Create the argocd namespace
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [google_container_cluster.primary]
}

# Install ArgoCD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  version    = "9.5.1"

  depends_on = [kubernetes_namespace_v1.argocd]
}
