output "j_auth" {
  depends_on = [
    data.kubernetes_secret.jenkins-pass
  ]
  value = "${data.kubernetes_secret.jenkins-pass.data["jenkins-admin-password"]}"
  sensitive = true
}

output "prod_url" {
  value = "${aws_lb.diploma-alb.dns_name}"
}

output "staging_url" {
  value = "${aws_lb.diploma-alb.dns_name}:8080"
}

output "jenkins_url" {
  value = "${aws_lb.diploma-alb.dns_name}:8081"
}

output "sonarqube_url" {
  value = "${aws_lb.diploma-alb.dns_name}:8082"
}

output "sq-token" {
  value = kubernetes_secret.sonarqube-secrets.data["token"]
  sensitive = true
}