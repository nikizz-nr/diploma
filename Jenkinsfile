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
                        if (env.BRANCH_NAME == 'main') || (env.BRANCH_NAME == 'production') {
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
        }
        stage('Print success!') {
            steps {
                script {
                    echo "Success!"
                }
            }
        }
    }
}
