pipeline {
    agent any

    tools {
        dockerTool 'docker'
    }

    // ตั้งค่าให้ Pipeline ทำงานอัตโนมัติเมื่อมีการ Push ไปที่ GitHub
    triggers {
        githubPush()
    }

    environment {
        // ชื่อ Image ที่จะใช้ build (ควรเป็นชื่อโปรเจกต์ของคุณ)
        APP_NAME    = 'my-nginx-web'
        IMAGE_TAG   = "${BUILD_NUMBER}"
        // ชื่อ Deployment ในไฟล์ k8s/deployment.yaml (จากที่คุณส่งมาคือชื่อ jenkins)
        K8S_DEPLOY_NAME = 'jenkins' 
        // ชื่อ Container ภายใน Deployment (จากที่คุณส่งมาคือชื่อ jenkins)
        K8S_CONTAINER_NAME = 'jenkins'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                // ดึงโค้ดล่าสุดจาก Git
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image: ${APP_NAME}:${IMAGE_TAG}..."
                    // Build image พร้อมติด tag เป็นเลข build และ latest
                    sh "docker build -t ${APP_NAME}:${IMAGE_TAG} -t ${APP_NAME}:latest ."
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Applying Kubernetes Manifests from jenkins folder..."
                    // เติมชื่อโฟลเดอร์ 'jenkins/' นำหน้าไฟล์ YAML ทุกไฟล์
                    sh "kubectl apply -f jenkins/deployment.yaml"
                    sh "kubectl apply -f jenkins/service.yaml"
                    sh "kubectl apply -f jenkins/ingress.yaml"
                    sh "kubectl apply -f jenkins/pv.yaml"  // ในรูปคุณใช้ชื่อ pv.yaml
                    sh "kubectl apply -f jenkins/pvc.yaml" // ในรูปคุณใช้ชื่อ pvc.yaml

                    echo "Updating Image to: ${APP_NAME}:${IMAGE_TAG}..."
                    sh "kubectl set image deployment/${K8S_DEPLOY_NAME} ${K8S_CONTAINER_NAME}=${APP_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Waiting for deployment to be ready..."
                    // รอจนกว่า Pod ใหม่จะรันสำเร็จ (timeout 2 นาที)
                    sh "kubectl rollout status deployment/${K8S_DEPLOY_NAME} --timeout=120s"
                    
                    // แสดงสถานะของ Resources ต่างๆ
                    sh "kubectl get pods,svc,ingress -l app=jenkins"
                }
            }
        }
    }

    // ส่วนสรุปผลการทำงาน
    post {
        success {
            echo "-----------------------------------------------------------"
            echo "✅ DEPLOYMENT SUCCESSFUL!"
            echo "Access your application at: http://my-nginx.local"
            echo "-----------------------------------------------------------"
        }
        failure {
            echo "-----------------------------------------------------------"
            echo "❌ DEPLOYMENT FAILED!"
            echo "Please check the logs above to identify the issue."
            echo "-----------------------------------------------------------"
        }
    }
}