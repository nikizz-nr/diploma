resource "helm_release" "fluent-bit" {
  depends_on = [
    aws_eks_node_group.diploma-ng,
    aws_eks_addon.vpccni,
    aws_eks_addon.coredns,
    aws_eks_addon.kubeproxy,
    kubernetes_namespace.fluentbit-env,
    aws_cloudwatch_log_group.diploma-lg,
  ]
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  name       = "fluentbit"
  namespace  = "fluentbit"
  cleanup_on_fail = true

  values = [
    "${file("fluentbit_values.yaml")}"
  ]

  set {
    name = "cloudWatch.region"
    value = "${var.region}"
  }

  set {
    name = "cloudWatch.logGroupName"
    value = "/aws/eks/${var.entity_name}/fluentbit"
  }

  set {
    name = "cloudWatch.autoCreateGroup"
    value = false
  }

}