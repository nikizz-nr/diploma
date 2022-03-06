pipeline {
    agent any
    environment { 
        ECR_URL = credentials('ecr-url')
        ECR_REGISTRY = credentials('ecr-registry')
    }
    stages {
        stage('Qualitygate') {
            environment {
                SCANNER_HOME = tool 'sscanner'
                PROJECT_NAME = "nhlstats"
            }
            steps {
                withSonarQubeEnv(installationName: 'sq-1', credentialsId: 'sq') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=${PROJECT_NAME}"
                }
            }
        }
        stage('Build image') {
            when {
                anyOf {
                    expression{env.BRANCH_NAME == 'main'}
                    expression{env.BRANCH_NAME == 'production'}
                }
            }
            steps {
                container('docker-dind') {
                    script {
                        withDockerRegistry(url: "${env.ECR_URL}", credentialsId: 'ecr-creds') {
                            def image = docker.build("${env.ECR_REGISTRY}:${env.GIT_COMMIT}", "-f docker/Dockerfile.app .")
                            image.push()
                            if (env.BRANCH_NAME == 'main') {
                                image.push('latest')
                            }
                            if (env.BRANCH_NAME == 'production') {
                                image.push('stable')
                            }
                        }
                    }
                }
            }
        }
        stage('database_update') {
            environment {
                DB_USER=credentials('db-user')
                DB_PASSWORD=credentials('db-password')
                DB_HOST=credentials('db-host')
                DATABASE=credentials('database')
            }
            // when {
            //     anyOf {
            //         expression{env.BRANCH_NAME == 'main'}
            //     }
            // }
            steps {
                container('mysql') {
                    script {
                        sh "echo \"[mysqld]\" > mysql_connect.cf"
                        sh "echo \"[client]\" >> mysql_connect.cf"
                        sh "echo \"host=${env.DB_HOST}\" >> mysql_connect.cf"
                        sh "echo \"user=${env.DB_USER}\" >> mysql_connect.cf"
                        sh "echo \"password=${env.DB_PASSWORD}\" >> mysql_connect.cf"
                        sh "cat mysql_connect.cf"
                        sh "echo \"#!/bin/bash\" > updatedb.sh"
                        sh "echo \"mysql --defaults-extra-file=mysql_connect.cf -e \\\"drop database if exists 'nhlstats-dev'\\\"\" >> updatedb.sh"
                        sh "echo \"mysql --defaults-extra-file=mysql_connect.cf -e \\\"create database 'nhlstats-dev'\\\"\" >> updatedb.sh"
                        sh "cat updatedb.sh"
                        sh "chmod +x updatedb.sh"
                        sh "./updatedb.sh"
                    }
                }
            }
        }
        stage('kubeops') {
            steps {
                container('k8s-control') {
                    script {
                        sh 'kubectl get ns'
                    }
                }
            }
        }
        stage('Print message') {
            steps {
                script {
                    echo "Success build!"
                }
            }
        }
    }
}
