resource "aws_lb" "diploma-alb" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  name               = "${var.entity_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_eks_cluster.diploma-cluster.vpc_config[0].cluster_security_group_id, data.aws_security_group.ingress-sg.id]
  subnets            = data.aws_subnets.diploma-subnets.ids
}

#Production env
resource "aws_lb_target_group" "diploma-app-prod-tg" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  name        = "${var.entity_name}-prod-tg"
  port        = var.app_prod_nodeport
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main-vpc.id
}

resource "aws_lb_target_group_attachment" "diploma-app-prod-tg-attachment" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  count = var.desired_nodes
  target_group_arn = aws_lb_target_group.diploma-app-prod-tg.arn
  target_id        = data.aws_instances.nodes.ids[count.index]
  port             = var.app_prod_nodeport
}

resource "aws_lb_listener" "diploma-app-prod-listener" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  load_balancer_arn = aws_lb.diploma-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.diploma-app-prod-tg.arn
  }
}

#Staging env
resource "aws_lb_target_group" "diploma-app-stg-tg" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  name        = "${var.entity_name}-stg-tg"
  port        = var.app_staging_nodeport
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main-vpc.id
}

resource "aws_lb_target_group_attachment" "diploma-app-stg-tg-attachment" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  count = var.desired_nodes
  target_group_arn = aws_lb_target_group.diploma-app-stg-tg.arn
  target_id        = data.aws_instances.nodes.ids[count.index]
  port             = var.app_staging_nodeport
}

resource "aws_lb_listener" "diploma-app-stg-listener" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  load_balancer_arn = aws_lb.diploma-alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.diploma-app-stg-tg.arn
  }
}

# Jenkins
resource "aws_lb_target_group" "jenkins-tg" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  name        = "jenkins-tg"
  port        = var.jenkins_nodeport
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main-vpc.id
}

resource "aws_lb_target_group_attachment" "jenkins-tg-attachment" {
  depends_on = [
    aws_eks_node_group.diploma-ng,
    data.aws_instances.nodes
  ]
  count = var.desired_nodes
  target_group_arn = aws_lb_target_group.jenkins-tg.arn
  target_id        = data.aws_instances.nodes.ids[count.index]
  port             = var.jenkins_nodeport
}

resource "aws_lb_listener" "jenkins-listener" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  load_balancer_arn = aws_lb.diploma-alb.arn
  port              = "8081"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-tg.arn
  }
}

# Sonarqube
resource "aws_lb_target_group" "sq-tg" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  name        = "sq-tg"
  port        = var.sq_nodeport
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main-vpc.id
}

resource "aws_lb_target_group_attachment" "sq-tg-attachment" {
  depends_on = [
    aws_eks_node_group.diploma-ng,
    data.aws_instances.nodes
  ]
  count = var.desired_nodes
  target_group_arn = aws_lb_target_group.sq-tg.arn
  target_id        = data.aws_instances.nodes.ids[count.index]
  port             = var.sq_nodeport
}

resource "aws_lb_listener" "sq-listener" {
  depends_on = [
    aws_eks_node_group.diploma-ng
  ]
  load_balancer_arn = aws_lb.diploma-alb.arn
  port              = "8082"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sq-tg.arn
  }
}
