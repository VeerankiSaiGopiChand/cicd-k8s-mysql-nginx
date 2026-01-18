# Trigger CI/CD pipeline

resource "kubernetes_service_account" "app_sa" {
  metadata {
    name      = "app-sa"
    namespace = "default"
  }
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "/home/runner/.kube/config"
}


# ---------------- MYSQL ----------------
resource "kubernetes_pod" "mysql" {
  metadata {
    name = "mysql-pod"
    labels = { app = "mysql" }
  }

  spec {
    service_account_name = kubernetes_service_account.app_sa.metadata[0].name

    container {
      name  = "mysql"
      image = "mysql:8.0"

      env {
        name  = "MYSQL_ROOT_PASSWORD"
        value = "root123"
      }

      env {
        name  = "MYSQL_DATABASE"
        value = "testdb"
      }

      port {
        container_port = 3306
      }
    }
  }
}

# ---------------- NGINX ----------------
resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-pod"
    labels = { app = "nginx" }
  }

  spec {
    service_account_name = kubernetes_service_account.app_sa.metadata[0].name

    container {
      name  = "nginx"
      image = "nginx:latest"

      port {
        container_port = 80
      }
    }
  }
}

