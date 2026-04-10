pipeline {
    agent any
    environment {
        APP_NAME = "my-nginx-web"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image: ${APP_NAME}:${IMAGE_TAG}..."
                    sh "docker build -t ${APP_NAME}:${IMAGE_TAG} -t ${APP_NAME}:latest ."
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Applying Web App Deployment..."
                    // 1. สั่งรันไฟล์ใหม่ที่เราแยกออกมา
                    sh "kubectl apply -f jenkins/web-app-deployment.yaml"
                    
                    echo "Updating Image to: ${APP_NAME}:${IMAGE_TAG}..."
                    // 2. สั่งเปลี่ยน Image ไปที่ my-nginx-app (ห้ามสั่งไปที่ deployment/jenkins)
                    sh "kubectl set image deployment/my-nginx-app nginx-container=${APP_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                sh "kubectl rollout status deployment/my-nginx-app"
            }
        }
    }
}