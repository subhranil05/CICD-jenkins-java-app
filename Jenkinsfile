pipeline{
    agent any
    stages{
        stage("sonar quality check"){
            agent {
                docker { 
                    image 'openjdk:11' 
                }
           }
            steps{
                script{
                        withSonarQubeEnv(credentialsId: 'sonar-token') {
                            sh 'chmod +x gradlew'
                            sh './gradlew sonar \
                                -Dsonar.projectKey=jenkins_gradle_cicd \
                                -Dsonar.host.url=http://172.17.0.2:9000'
                    }
                }
            }
        }
    }
}