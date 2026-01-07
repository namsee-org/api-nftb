pipeline {
    agent any
    environment {
        REGISTRY = 'ghcr.io'
        IMAGE_NAME = 'namsee-org/api-nftb'
        GITHUB_CREDS = credentials('github-registry-pat')
        SONARCLOUD_TOKEN = credentials('SONAR_TOKEN')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarCloud') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=${env.SONAR_TOKEN} \
                        -Dsonar.organization=${env.SONAR_ORGANIZATION} \
                        -Dsonar.login=${SONARCLOUD_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    def tag = "pr-${env.CHANGE_ID ?: 'local'}-${env.BUILD_NUMBER}"
                    def full = "${REGISTRY}/${IMAGE_NAME}:${tag}"

                    sh "echo ${GITHUB_CREDS_PSW} | docker login ${REGISTRY} -u ${GITHUB_CREDS_USR} --password-stdin"
                    docker.build(full).push()
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout ghcr.io'
            cleanWs()
        }
    }
}
