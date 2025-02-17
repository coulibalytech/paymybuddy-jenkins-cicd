/* import shared library */
@Library('shared-library@master')_

pipeline{
           tools {
        maven "Maven" // Nom de l'installation Maven configurée dans Manage Jenkins
          }
          environment{
              IMAGE_NAME_DB = "paymybuddy-db"
              IMAGE_NAME_BACKEND = "paymybuddy-paymybuddy-backend"
              IMAGE_NAME_BACKEND_C = "paymybuddy-backend"
              IMAGE_TAG = "latest"
              ENV_FILE = "${WORKSPACE}/.env"
              STAGING = "coulibaltech-staging"
              PRODUCTION = "coulibaltech-production"
              REPOSITORY_NAME = "coulibalytech"

            // Staging EC2
              STAGING_IP = "192.168.56.18"
              STAGING_USER = "vagrant"
              STAGING_DEPLOY_PATH = "/home/ubuntu/app/staging"
              STAGING_HTTP_PORT = "80" // Port spécifique pour staging

             // Production EC2
              PRODUCTION_IP = "192.168.56.19"
              PRODUCTION_USER = "vagrant"
              PRODUCTION_DEPLOY_PATH = "/home/ubuntu/app/production"
              PRODUCTION_HTTP_PORT = "80" // Port spécifique pour production

              SSH_CREDENTIALS_STAGING_ID = "staging_ssh_credentials"
              SSH_CREDENTIALS_PRODUCTION_ID = "production_ssh_credentials"
              DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id'

              SONAR_AUTH_TOKEN = credentials('sonarcloud_token-id')
          }
            agent none
            stages{   
                stage('Checkout') {
                    agent any    
                    steps {
                          checkout scm // Récupère le code source
                      }
                }      
                stage("Build image paymybuddy-db and backend with Docker compose") {
                    agent any
                    steps{
                        script{
                           echo "Building Docker images (DB + Backend)"
                              withCredentials([usernamePassword(credentialsId: 'ssh-username-password', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
                               sh '''
                                remote_cmds="
                                  cd paymybuddy-jenkins-cicd &&
                                  docker compose up -d --build &&
                                  sleep 5
                                  "
                                  # executing remote commands
                                  sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no ${STAGING_USER}@192.168.56.17 "\$remote_cmds"
                                  
                                  '''
                              }
                             
                        }
                    }
                    
                }
                stage("Test Docker Images") {
                      agent any
                      steps {
                          script {

                              echo "Testing database availability on 3306"
                              sh 'docker ps | grep  "3306"'
                                    
                              echo "Testing backend availability on 8181"
                              sh 'docker ps | grep  "8181"'
                            }
                        }
                }
                stage('SonarCloud Analysis') {
                      agent any    
                      steps {
                          script {
                              withCredentials([usernamePassword(credentialsId: 'ssh-username-password', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
                              sh '''
                                  mvn sonar:scanner \
                                  -Dsonar.projectKey=coulibalytech_paymybuddy-jenkins-cicd \
                                  -Dsonar.organization=cheick.coulibaly \
                                  -Dsonar.host.url=https://sonarcloud.io \
                                  -Dsonar.login=$SONAR_AUTH_TOKEN
                              '''     
                              }
                             
                          }
                      }
                  }
                stage("Login to Docker Hub Registry") {
                    agent any      
                    steps {
                            script {
                                echo "Connexion au registre Docker hub"
                            withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                                sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                            }
                        }
                    }

                }

                stage('Push Images(DB & Backend) in docker hub') {
                        agent any
                        steps {
                            script {
                                echo "Pousser l'image Docker vers le registre..."
                                sh "docker commit ${IMAGE_NAME_DB} ${IMAGE_NAME_DB}:${IMAGE_TAG}"
                                sh "docker tag ${IMAGE_NAME_DB}:${IMAGE_TAG} ${REPOSITORY_NAME}/${IMAGE_NAME_DB}:${IMAGE_TAG}"
                                sh "docker push ${REPOSITORY_NAME}/${IMAGE_NAME_DB}:${IMAGE_TAG}"
                                sh "docker tag ${IMAGE_NAME_BACKEND}:${IMAGE_TAG} ${REPOSITORY_NAME}/${IMAGE_NAME_BACKEND}:${IMAGE_TAG}"
                                sh "docker push ${REPOSITORY_NAME}/${IMAGE_NAME_BACKEND}:${IMAGE_TAG}"
                                sh "docker logout"      
                            }
                        }
                }
                stage("Clean container") {
                            agent any
                            steps{
                                echo "========executing Clean container========"
                                script{
                                  sh '''
                                  docker stop ${IMAGE_NAME_DB}
                                  docker stop ${IMAGE_NAME_BACKEND_C}
                                  docker rm -f ${IMAGE_NAME_DB}
                                  docker rm -f ${IMAGE_NAME_BACKEND_C}
                                    '''
                                }
                            }
                            
                }
                stage("Deploy in staging") {
                  when{
                      expression {GIT_BRANCH == 'origin/master'}
                    }
                  agent any
            
                  steps{
                      echo "========executing Deploy in staging========"
                      
                      script{
                          echo "Uploading Docker image to Staging test"     
                         withCredentials([usernamePassword(credentialsId: 'ssh-username-password', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
                             sh '''
                                echo "Deploying app..."
                               # defining remote commands
                               remote_cmds="
                               docker rm -f ${IMAGE_NAME_DB} 2>/dev/nul || true && 
                               docker rm -f ${IMAGE_NAME_BACKEND} 2>/dev/nul || true && 
                               rm -rf paymybuddy-jenkins-cicd 2>/dev/nul || true &&
                               git clone https://github.com/coulibalytech/paymybuddy-jenkins-cicd.git &&
                               cd paymybuddy-jenkins-cicd &&
                               docker compose up -d --build
                               sleep 5
                               "
                               # executing remote commands
                               sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no ${STAGING_USER}@192.168.56.18 "\$remote_cmds"
                               '''

                            }
                        
                        }
                    }
                }
                stage("Test in staging") {
                    agent any
                    steps{
                        echo "========executing Test staging========"
                        script{
                                withCredentials([usernamePassword(credentialsId: 'ssh-username-password', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
                               echo "Testing database availability on 3306"          
                               sh '''
                               # defining remote commands
                               remote_cmds1="
                               docker ps | grep  "3306"
                               "
                               sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no ${STAGING_USER}@192.168.56.18 "\$remote_cmds1"
                               '''
                                    
                               echo "Testing backend availability on 8181"
                               sh '''
                               # defining remote commands
                               remote_cmds2="
                               docker ps | grep  "8181"
                               "
                                sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no ${STAGING_USER}@192.168.56.18 "\$remote_cmds2"
                               '''          
                             
                            }
                        }
                    
                    }
                }
    
                stage("Deploy in production") {
                  when{
                      expression {GIT_BRANCH == 'origin/master'}
                   }
                  agent any

                  steps{
                      echo "========executing Deploy in production========"
                      
                      script{
                            withCredentials([usernamePassword(credentialsId: 'ssh-username-password', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
                             sh '''
                                echo "Deploying app..."
                               # defining remote commands
                               remote_cmds="
                               docker rm -f ${IMAGE_NAME_DB} 2>/dev/nul || true && 
                               docker rm -f ${IMAGE_NAME_BACKEND} 2>/dev/nul || true && 
                               rm -rf paymybuddy-jenkins-cicd 2>/dev/nul || true &&
                               git clone https://github.com/coulibalytech/paymybuddy-jenkins-cicd.git &&
                               cd paymybuddy-jenkins-cicd &&
                               docker compose up -d --build
                               sleep 5
                               "
                               # executing remote commands
                               sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no ${PRODUCTION_USER}@192.168.56.19 "\$remote_cmds"
                               '''

                            }
                        
                        }
                    }
                }
               stage("Test in production") {
                    agent any
                    steps{
                        echo "========executing Test production========"
                        script{
                               withCredentials([usernamePassword(credentialsId: 'ssh-username-password', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
                               echo "Testing database availability on 3306"          
                               sh '''
                               # defining remote commands
                               remote_cmds1="
                               docker ps | grep  "3306"
                               "
                               sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no ${STAGING_USER}@192.168.56.18 "\$remote_cmds1"
                               '''
                                    
                               echo "Testing backend availability on 8181"
                               sh '''
                               # defining remote commands
                               remote_cmds2="
                               docker ps | grep  "8181"
                               "
                                sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no ${STAGING_USER}@192.168.56.18 "\$remote_cmds2"
                               '''          
                             
                            }
                        }
                    
                    }
               
                }
                      
            }

            post {
                    always { 
                               script {
                              /* Use slackNotifier.groovy from shared library and provide current build result as parameter*/
                              slackNotifier currentBuild.result
                                    }
                     }
                }

    
          
        }
          
