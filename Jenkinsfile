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
            when {
                anyOf {
                    expression{env.BRANCH_NAME == 'main'}
                }
            }
            steps {
                container('mysql') {
                    script {
                        sh "echo \"#!/bin/bash\" > updatedb.sh"
                        sh "echo \"mysql -h${env.DB_HOST} -u${env.DB_USER} -p${env.DB_PASSWORD} -e \\\"DROP DATABASE IF EXISTS ${env.DATABASE}_dev;\\\"\" >> updatedb.sh"
                        sh "echo \"mysql -h${env.DB_HOST} -u${env.DB_USER} -p${env.DB_PASSWORD} -e \\\"CREATE DATABASE ${env.DATABASE}_dev\\\"\" >> updatedb.sh"
                        sh "/bin/bash ./updatedb.sh"
                    }
                }
            }
        }
        stage('kubeops') {
            when {
                anyOf {
                    expression{env.BRANCH_NAME == 'main'}
                    expression{env.BRANCH_NAME == 'production'}
                }
            }
            steps {
                container('k8s-control') {
                    script {
                        sh 'helm repo add diploma https://nikizz-nr.github.io/diploma/'
                        if (env.BRANCH_NAME == 'main') {
                            sh "helm -n staging install diploma diploma/nhlstats --set image=${env.ECR_REGISTRY}"
                        }
                        if (env.BRANCH_NAME == 'production') {
                            sh "helm -n production install diploma diploma/nhlstats --set image=${env.ECR_REGISTRY} --set tag=stable --set nodeport=32221"
                        }
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
