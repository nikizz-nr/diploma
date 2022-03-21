resource "helm_release" "sonarqube" {
  depends_on = [
    aws_eks_node_group.diploma-ng,
    aws_eks_addon.vpccni,
    aws_eks_addon.coredns,
    aws_eks_addon.kubeproxy,
    kubernetes_namespace.jenkins-env,
    kubernetes_storage_class.sonarqube-sc,
    kubernetes_persistent_volume_claim.sonarqube-pvc,
  ]
  name       = "sonarqube"
  chart = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  namespace = "jenkins"
  cleanup_on_fail = true

  values = [
    "${file("sq_values.yaml")}"
  ]

  set {
    name = "account.adminPassword"
    value = "${var.sq_password}"
  }
}

data "external" "sonarqube-project" {
  depends_on = [
    helm_release.sonarqube
  ]
  program = ["/bin/bash", "sonarqube_config.sh", "${aws_lb.diploma-alb.dns_name}", "${var.sq_password}", "${var.app_name}"]
}

resource "kubernetes_secret" "sonarqube-secrets" {
  depends_on = [
    kubernetes_namespace.jenkins-env,
    data.external.sonarqube-project,
  ]
  metadata {
    name = "sq-creds"
    namespace = "jenkins"
  }
  data = {
    token = data.external.sonarqube-project.result["token"]
  }
}