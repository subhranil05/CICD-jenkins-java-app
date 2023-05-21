pipeline{
    agent any
    environment{
        VERSION = "${env.BUILD_ID}"
    }
    stages{
        stage("checkout"){
            steps{
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/subhranil05/CICD-jenkins-java-app']])
            }
        }   
        stage("sonar quality check"){
            agent {
                docker { 
                    image 'openjdk:11' 
                }
           }
            steps{
                script{
                        withSonarQubeEnv(installationName: 'sonarserver') {
                            sh 'chmod +x gradlew'
                            sh './gradlew sonarqube'
                    }
                    // timeout(time: 1, unit: 'HOURS') {
                    //   def qg = waitForQualityGate()
                    //   if (qg.status != 'OK') {
                    //        error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    //   }
                    // }
                }
            }
        }

        stage("build docker image & push image"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'docker_pwd', variable: 'docker_pwd')]) {
                        sh '''
                            docker build -t subhranil05/simple-webapp:${VERSION} -f Dockerfile .
                            docker login -u subhranil05 -p $docker_pwd
                            docker push subhranil05/simple-webapp:${VERSION}
                            docker rmi subhranil05/simple-webapp:${VERSION}
                        '''
                    }
                }
            }
        }
    }
}