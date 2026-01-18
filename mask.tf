# Trigger CI/CD pipeline
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

      port { container_port = 3306 }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata { name = "mysql-service" }

  spec {
    selector = { app = "mysql" }
    port {
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
  }
}

# ---------------- NGINX ----------------
resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-pod"
    labels = { app = "nginx" }
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:latest"

      port { container_port = 80 }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata { name = "nginx-service" }

  spec {
    selector = { app = "nginx" }

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }

    type = "NodePort"
  }
}
