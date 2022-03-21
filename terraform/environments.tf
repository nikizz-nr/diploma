resource "kubernetes_namespace" "fluentbit-env" {
  metadata {
    name = "fluentbit"
  }
}

resource "kubernetes_namespace" "staging-env" {
  metadata {
    name = "staging"
  }
}

resource "kubernetes_secret" "staging-secrets" {
  depends_on = [
    kubernetes_namespace.staging-env
  ]
  metadata {
    name = "app-config"
    namespace = "staging"
  }
  data = {
    DB_PASSWORD = var.db_password
    DB_USER = var.db_user
    DATABASE = "${var.app_name}_dev"
    DB_HOST = aws_db_instance.diploma-rds.address
    SECRET_KEY = var.django_secret_key
    DEBUG = "1"
    ALLOWED_HOSTS = var.allowed_hosts
  }
}

resource "kubernetes_namespace" "prod-env" {
  metadata {
    name = "production"
  }
}

resource "kubernetes_secret" "prod-secrets" {
  depends_on = [
    kubernetes_namespace.prod-env
  ]
  metadata {
    name = "app-config"
    namespace = "production"
  }
  data = {
    DB_PASSWORD = var.db_password
    DB_USER = var.db_user
    DATABASE = var.app_name
    DB_HOST = aws_db_instance.diploma-rds.address
    SECRET_KEY = var.django_secret_key
    DEBUG = "0"
    ALLOWED_HOSTS = var.allowed_hosts
  }
}

resource "kubernetes_namespace" "jenkins-env" {
  metadata {
    name = "jenkins"
  }
}


resource "kubernetes_secret" "jenkins-secrets" {
  depends_on = [
    kubernetes_namespace.jenkins-env
  ]
  metadata {
    name = "jenkins-creds"
    namespace = "jenkins"
  }
  data = {
    db-password = var.db_password
    db-user = var.db_user
    database = var.app_name
    db-host = aws_db_instance.diploma-rds.address
    mail-address = var.jenkins_mail_address
    mail-password = var.jenkins_mail_password
    ecr-login = data.aws_ecr_authorization_token.ecr-creds.user_name
    ecr-password = data.aws_ecr_authorization_token.ecr-creds.password
    ecr-url = data.aws_ecr_authorization_token.ecr-creds.proxy_endpoint
    ecr-image = aws_ecr_repository.diploma-repo.repository_url
    jenkins-url = aws_lb.diploma-alb.dns_name
    devops-mail = var.owner
  }
}
