pipeline{
    agent any
    stages{
        stage("sonar quality check"){
            steps{
                echo "========SonarQube test========"
                agent{
                    docker{
                        image 'openjdk:11'
                    }
                }
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube'
                }
            }
            }
        }
    }
}