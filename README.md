# ASP.NET Multi-Tenant Demo on GKE with GitOps

This repository contains a complete demonstration of a multi-tenant ASP.NET 10 application deployed on Google Kubernetes Engine (GKE) Autopilot, utilizing Cloud SQL (MSSQL) and managed via a fully automated GitOps pipeline with Cloud Build and ArgoCD.

## Features

*   **Application**: ASP.NET 10.0 Razor Pages app with Entity Framework Core 9.0.
*   **Multi-Tenancy**: Separate namespaces and database instances for `Tenant A` and `Tenant B`.
*   **Database**: Cloud SQL for SQL Server (MSSQL) with secure connectivity via Cloud SQL Auth Proxy sidecar.
*   **Secrets Management**: External Secrets Operator integrating with Google Secret Manager.
*   **GitOps**: Automated manifest updates via Cloud Build and continuous deployment via ArgoCD.
*   **Infrastructure**: Fully provisioned via Terraform.

## Project Structure

```text
├── app/                  # ASP.NET 10 Source Code & Dockerfile
├── terraform/            # Infrastructure as Code (GKE, Cloud SQL, Registry)
├── chart/                # Helm Chart for the application
│   ├── templates/        # K8s manifests as templates
│   ├── values-tenant-a.yaml # Tenant A specific overrides
│   └── values-tenant-b.yaml # Tenant B specific overrides
└── argocd/               # ArgoCD Application manifests
```

## Getting Started

### Prerequisites

*   Google Cloud SDK installed and configured.
*   Terraform installed.
*   Helm installed.
*   A GitHub repository (or other Git provider) to host this code.

### Step 1: Provision Infrastructure

Navigate to the `terraform` directory and apply the configuration:

```bash
cd terraform
terraform init
terraform apply \
  -var="project_id=YOUR_PROJECT_ID" \
  -var="tenant_a_db_password=YourSecurePassword1" \
  -var="tenant_b_db_password=YourSecurePassword2"
```

### Step 2: Configure Git Authentication for Cloud Build

Cloud Build needs to push image tag updates back to your repository.

1.  Create a GitHub Personal Access Token (PAT) with `repo` scope.
2.  Store it in Google Secret Manager as a secret named `git-token`.
3.  Grant your Cloud Build service account (`YOUR_PROJECT_NUMBER@cloudbuild.gserviceaccount.com`) the **Secret Manager Secret Accessor** role for that secret.

### Step 3: Build and Push the Application

Run the build pipeline. This will build the Docker image, push it to Artifact Registry, and update the image tag in your Helm values file.

```bash
gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_REGION=YOUR_REGION,_REPO_NAME=YOUR_REPO_NAME
```
> [!IMPORTANT]
> Update the Git repository URL in `cloudbuild.yaml` to point to your repo before running.

### Step 4: Deploy with ArgoCD

1.  Connect your cluster and ensure ArgoCD is running (Terraform installs it automatically).
2.  Apply the ArgoCD application manifests:

```bash
kubectl apply -f argocd/
```

ArgoCD will pick up the Helm chart and deploy both tenants to their respective namespaces.

## Accessing the Environment

### ArgoCD UI
1.  Get the admin password:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    ```
2.  Port forward the server:
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```
3.  Open `https://localhost:8080` in your browser.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
