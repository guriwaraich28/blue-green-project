pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTIVE_ENV',
            choices: ['blue', 'green'],
            description: 'Select which environment should receive traffic'
        )
        string(
            name: 'IMAGE_TAG',
            defaultValue: '',
            description: 'Enter image tag to deploy (leave empty for latest build)'
        )
    }

    environment {
        DOCKER_IMAGE = "guriwaraich/flask-crud"
        IMAGE_TAG = "${params.IMAGE_TAG ?: BUILD_NUMBER}"
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh "docker build -t $DOCKER_IMAGE:$IMAGE_TAG ."
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh "docker push $DOCKER_IMAGE:$IMAGE_TAG"
            }
        }

        stage('Terraform Deploy') {
            steps {
                dir('terraform') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh """
                        terraform init
                        terraform apply -auto-approve \
                        -var="image_tag=${IMAGE_TAG}" \
                        -var="active_environment=${params.ACTIVE_ENV}"
                        """
                    }
                }
            }
        }
    }
}
