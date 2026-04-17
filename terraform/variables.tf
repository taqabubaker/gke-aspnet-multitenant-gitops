variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "gke-gitops-demo"
}

variable "tenant_a_db_password" {
  description = "Password for Tenant A database"
  type        = string
  sensitive   = true
}

variable "tenant_b_db_password" {
  description = "Password for Tenant B database"
  type        = string
  sensitive   = true
}

variable "artifact_registry_name" {
  description = "The name of the Artifact Registry repository"
  type        = string
  default     = "my-app-repo"
}
