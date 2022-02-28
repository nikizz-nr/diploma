pipeline {
    agent any
    environment { 
        ECR_URL = credentials('ecr-url')
        ECR_REGISTRY = credentials('ecr-registry')
    }
    stages {
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
        stage('Print success!') {
            steps {
                script {
                    echo "Success build!"
                }
            }
        }
    }
}
