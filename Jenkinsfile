pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: dind-agent
spec:
  containers:
  - name: dind
    image: docker:20.10.12-dind
    imagePullPolicy: Always
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
      - name: docker-graph-storage
        mountPath: /var/lib/docker
  volumes:
    - name: docker-graph-storage
      emptyDir: {}
"""
        }
    }
    environment { 
        STEXT = credentials('secret_text') 
    }
    stages {
        stage('Build image') {
            steps {
                container('dind') {
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
