resource "kubernetes_service_account" "jenkins-sa" {
  depends_on = [
    kubernetes_namespace.jenkins-env
  ]
  metadata {
    name      = "jenkins"
    namespace = "jenkins"
    labels = {
      env = "jenkins"
    }
  }
}

resource "kubernetes_cluster_role" "jenkins-role" {
  metadata {
    name = "jenkins"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      env = "jenkins"
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["statefulsets", "services", "replicationcontrollers", "replicasets", "podtemplates", "podsecuritypolicies", "pods", "pods/log", "pods/exec", "podpreset", "poddisruptionbudget", "persistentvolumes", "persistentvolumeclaims", "jobs", "endpoints", "deployments", "deployments/scale", "daemonsets", "cronjobs", "configmaps", "namespaces", "events", "secrets"]
    verbs      = ["create", "get", "watch", "delete", "list", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "update" ]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins-rb" {
  metadata {
    name = "jenkins"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      env = "jenkins"
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "jenkins"
  }
  subject {
    kind      = "Group"
    name      = "system:serviceaccounts:jenkins"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service_account" "k8s-sa" {
  depends_on = [
    kubernetes_namespace.jenkins-env
  ]
  metadata {
    name      = "k8s-control"
    namespace = "jenkins"
  }
}

resource "kubernetes_cluster_role" "k8s-role" {
  metadata {
    name = "k8s-control"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["create", "get", "watch", "delete", "list", "patch", "update"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["create", "get", "watch", "delete", "list", "patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "k8s-rb" {
  metadata {
    name = "k8s-control"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "k8s-control"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "k8s-control"
    namespace = "jenkins"
    api_group = ""
  }
}

resource "helm_release" "jenkins-chart" {
  depends_on = [
    aws_eks_node_group.diploma-ng,
    aws_eks_addon.vpccni,
    aws_eks_addon.coredns,
    aws_eks_addon.kubeproxy,
    kubernetes_secret.jenkins-secrets,
    kubernetes_namespace.jenkins-env,
    kubernetes_storage_class.jenkins-sc,
    kubernetes_persistent_volume_claim.jenkins-pvc,
    kubernetes_cluster_role.jenkins-role,
    kubernetes_cluster_role_binding.jenkins-rb,
    kubernetes_service_account.jenkins-sa,
    kubernetes_cluster_role_binding.k8s-rb,
    kubernetes_service_account.k8s-sa,
    kubernetes_cluster_role.k8s-role,
    helm_release.sonarqube,
    kubernetes_secret.sonarqube-secrets,
    data.external.sonarqube-project,
  ]
  name       = "jenkins"
  chart      = "https://github.com/jenkinsci/helm-charts/releases/download/jenkins-3.11.4/jenkins-3.11.4.tgz"
  namespace  = "jenkins"

  values = [
    "${file("jenkins_values.yaml")}"
  ]

  set {
    name = "controller.nodePort"
    value = "${var.jenkins_nodeport}"
  }
  set {
    name = "controller.nodeSelector.topology\\.kubernetes\\.io/zone"
    value = "${var.jenkins_az}"
  }
}

data "kubernetes_secret" "jenkins-pass" {
  depends_on = [
    helm_release.jenkins-chart,
    kubernetes_namespace.jenkins-env
  ]
  metadata {
    name = "jenkins"
    namespace = "jenkins"
  }
  binary_data = {
  }
}
