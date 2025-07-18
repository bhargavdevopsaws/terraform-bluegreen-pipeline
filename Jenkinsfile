pipeline {
  agent any

  parameters {
    string(name: 'ENVIRONMENT', defaultValue: 'blue', description: 'Environment (blue/green)')
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/bhargavdevopsaws/terraform-bluegreen-pipeline.git'
      }
    }

    stage('Verify Environment Folder') {
      steps {
        sh 'echo "Root directory content:" && ls -l'
        sh "echo \"Contents of '${params.ENVIRONMENT}/':\" && ls -l ${params.ENVIRONMENT}"
      }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access' ]]) {
          dir("${params.ENVIRONMENT}") {
            sh 'terraform init'
          }
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access' ]]) {
          dir("${params.ENVIRONMENT}") {
            sh 'terraform plan -var-file="terraform.tfvars" -out=tfplan'
          }
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access' ]]) {
          dir("${params.ENVIRONMENT}") {
            sh 'terraform apply tfplan'
          }
        }
      }
    }

    stage('Terraform Output') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access' ]]) {
          dir("${params.ENVIRONMENT}") {
            sh 'terraform output'
          }
        }
      }
    }
  }
}
