resource "kubernetes_storage_class" "jenkins-sc" {
  metadata {
    name = "jenkins-sc"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp2"
    fsType = "ext4"
  }
  allowed_topologies {
    match_label_expressions {
      key = "topology.kubernetes.io/zone"
      values = [var.jenkins_az]
    }
  }
}

resource "kubernetes_storage_class" "sonarqube-sc" {
  metadata {
    name = "sonarqube-sc"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp2"
    fsType = "ext4"
  }
  allowed_topologies {
    match_label_expressions {
      key = "topology.kubernetes.io/zone"
      values = ["eu-central-1c"]
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins-pvc" {
  depends_on = [
    kubernetes_storage_class.jenkins-sc
  ]
  metadata {
    name = "jenkins-pvc"
    namespace = "jenkins"
  }
  spec {
    storage_class_name = "jenkins-sc"
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "sonarqube-pvc" {
  depends_on = [
    kubernetes_storage_class.sonarqube-sc
  ]
  metadata {
    name = "sonarqube-pvc"
    namespace = "jenkins"
  }
  spec {
    storage_class_name = "sonarqube-sc"
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}