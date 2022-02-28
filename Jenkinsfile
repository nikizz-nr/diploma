pipeline {
    agent any
    environment { 
        STEXT = credentials('ecr-url') 
    }
    stages {
        stage('Build image') {
            steps {
                container('docker-dind') {
                    sh "docker build -t nhlstats:$BUILD_NUMBER -f docker/Dockerfile.app ."
                }
            }
        }
        stage('Print env') {
            steps {
                script {
                    sh "printenv"
                }
            }
        }
    }
}
