pipeline {
    agent any
    environment { 
        ECR_URL = credentials('ecr-url')
        ECR_REGISTRY = credentials('ecr-registry')
    }
    stages {
        stage('Build image') {
            steps {
                container('docker-dind') {
                    script {
                        sh 'ls -l'
                        withDockerRegistry(url: "${env.ECR_URL}", credentialsId: 'ecr-creds') {
                            def image = docker.build("${env.ECR_REGISTRY}:${env.GIT_COMMIT}", "-f docker/Dockerfile.app .")
                            image.push()
                        }
                    }
                }
            }
        }
        stage('Print env') {
            steps {
                script {
                    echo "Success!"
                }
            }
        }
    }
}
