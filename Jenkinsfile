pipeline {
    agent any

    environment {
        // Naming label configured in Manage Jenkins -> System
        SONAR_SERVER_NAME = 'SonarQube'
        
        // Docker Repository Details
        DOCKER_REGISTRY   = 'docker.io'
        IMAGE_NAME        = 'mreddi8997/mreddi8997_repo'
        IMAGE_TAG         = "${env.BUILD_NUMBER}" // Uses the sequential Jenkins build number as the tag
    }

    stages {
        stage('1. Checkout SCM') {
            steps {
                checkout scm
                echo "Successfully synchronized source code from GitHub webhook trigger."
            }
        }

        stage('2. Code Analysis with SonarQube') {
            tools {
                // This tells Jenkins to automatically download and use the tool we named in the UI
                sonarScanner 'sonar-scanner'
            }
            steps {
                withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                    echo "Starting native code quality scan..."
                    
                    // Run the native scanner tool directly in the workspace
                    sh "sonar-scanner -Dsonar.projectKey=my-devops-app -Dsonar.sources=."
                }
            }
        }
        
        stage('2b. Quality Gate Verification') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('3a. Build Image via Docker Compose') {
            steps {
                echo "Building Docker Image using Docker Compose configurations..."
                
                // Injecting the environment variables straight into the compose build command
                sh "IMAGE_NAME=${IMAGE_NAME} IMAGE_TAG=${IMAGE_TAG} docker compose build"
                
                // Tagging it as latest for local workspace cache stability
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('3b. Vulnerability Scan with Trivy') {
            steps {
                echo "Scanning Docker image for security vulnerabilities with Trivy..."
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}"
                echo "✅ Trivy scan passed! No high/critical vulnerabilities found."
            }
        }

        stage('3c. Push to Docker Repository') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    echo "Logging into Docker Registry..."
                    sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin ${DOCKER_REGISTRY}"
                    
                    echo "Pushing images to registry..."
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker Compose and building storage workspace..."
            // Safely tears down local storage layers built by compose to protect disk space
            sh "IMAGE_NAME=${IMAGE_NAME} IMAGE_TAG=${IMAGE_TAG} docker compose down --rmi local || true"
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest || true"
            cleanWs()
        }
    }
}
    

