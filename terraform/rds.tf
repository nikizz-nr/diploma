resource "aws_db_subnet_group" "diploma-rds-subg" {
  name       = "${var.entity_name}-subg"
  subnet_ids = data.aws_subnets.diploma-subnets.ids
}

resource "aws_db_instance" "diploma-rds" {
  depends_on = [
    aws_eks_cluster.diploma-cluster
  ]
  allocated_storage    = 5
  identifier = "${var.entity_name}-db"
  db_subnet_group_name = aws_db_subnet_group.diploma-rds-subg.name
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "${var.app_name}"
  username             = "${var.db_user}"
  password             = "${var.db_password}"
  skip_final_snapshot  = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  vpc_security_group_ids = ["${aws_eks_cluster.diploma-cluster.vpc_config[0].cluster_security_group_id}"]
}

