#Main variables
variable "region" {
    description = "Region to search for vpc"
}

variable "owner" {
    description = "Object owner for tag"
}

variable "entity_name" {
    default = "nr-devops-diploma"
    description = "Project name"
}

variable "ingress_sg" {
    description = "Global ingress security group name"
}

variable "desired_nodes" {
    default = 3
    description = "Number of nodes in cluster"
}

variable "min_nodes" {
    default = 3
    description = "Number of nodes in cluster"
}

variable "max_nodes" {
    default = 3
    description = "Number of nodes in cluster"
}

#App variables
variable "app_prod_nodeport" {
    default = 32221
    description = "Nodeport for application in production environment"
}

variable "app_staging_nodeport" {
    default = 32222
    description = "Nodeport for application in staging environment"
}

variable "app_name" {
    default = "nhlstats"
    description = "Application name"
}

variable "db_user" {
    description = "Database username"
}

variable "db_password" {
    description = "Database password"
    sensitive = true
}

variable "django_secret_key" {
    description = "App secret key"
    sensitive = true
}

variable "allowed_hosts" {
    description = "Allowed hosts config"
}

#Jenkins variables
variable "jenkins_mail_address" {
    description = "Jenkins admin mail address"
}

variable "jenkins_mail_password" {
    description = "Jenkins admin mail password"
    sensitive = true
}

variable "jenkins_az" {
    description = "AZ to place Jenkins (dirty hack to bypass OIDC restrictions)"
}

variable "jenkins_nodeport" {
    default = 32290
    description = "Nodeport for jenkins"
}

#Sonarqube
variable "sq_nodeport" {
    default = 32300
    description = "Nodeport for sonarqube"
}

variable "sq_password" {
    description = "Password for sonarqube"
    sensitive = true
}
