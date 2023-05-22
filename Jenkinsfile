pipeline{
    agent any
    environment{
        VERSION = "${env.BUILD_ID}"
        AWS_ACCOUNT_ID = '123456789012'
        AWS_REGION = 'us-west-2'
        ECR_REGISTRY = '${AWS_ACCOUNT_ID}.dkr.ecr.{AWS_REGION}.amazonaws.com'
        HELM_CHART_DIR = 'kubernetes/myapp'
        HELM_CHART_NAME = 'myapp'
        HELM_CHART_VERSION = $(helm show chart ${HELM_CHART_NAME} | grep version | cut -d: -f 2 |tr -d ' ')
        PACKAGED_CHART = ${HELM_CHART_NAME}-${HELM_CHART_VERSION}.tgz
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
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
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

        stage("Helm chart verification by datree"){
            steps{
                script{
                    dir('kubernetes/') {
                        withEnv(['DATREE_TOKEN=GJdx2cP2TCDyUY3EhQKgTc']) {
                            sh 'helm datree test myapp/'
                        }
                    }
                }
            }
        }

        stage("package helm chart and push to ECR"){
            steps{
                script{
                    dir('kubernetes/') {
                        withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
                            sh '''
                                // package helm chart

                                helm package ${HELM_CHART_DIR} --version $HELM_CHART_VERSION

                                // push helm chart to ecr
                                
                                aws ecr create-repository \
                                    --repository-name ${HELM_CHART_NAME} \
                                    --region ${AWS_REGION}

                                aws ecr get-login-password \
                                    --region ${AWS_REGION} | helm registry login \
                                    --username AWS \
                                    --password-stdin ${ECR_REGISTRY}

                                helm push ${PACKAGED_CHART} oci://${ECR_REGISTRY}
                                rm ${PACKAGED_CHART}
                            '''
                        }
                    }
                }
            }
        }

        stage("Deploy helm charts to kubernetes"){
            steps{
                script{
                    withCredentials([kubeconfigFile(credentialsId: 'kubernetes-config', variable: 'KUBECONFIG')]) {
                        dir('kubernetes/') {
                            sh 'helm upgrade --install --set image.repository="subhranil05/simple-webapp" --set image.tag="${VERSION}" myjavaapp myapp/'
                        }
                    }    
                }
            }
        }
    }
    post {
            always {
                mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "subhranilghosh05@gmail.com";  
            }
        }

}