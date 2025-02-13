/* import shared library */
@Library('shared-library@master')_

pipeline{
          environment{
              IMAGE_NAME_DB = "paymybuddy-db"
              IMAGE_NAME_BACKEND = "paymybuddy-backend"     
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
          }
          agent none
          stages{     
                stage("Build image paymybuddy-db and backend with Docker compose") {
                    agent any
                    steps{
                        script{
                           echo "Building Docker images (DB + Backend)"
                              sh """
                                  docker compose up -d --build
                                  sleep 5
                              """
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
                        docker stop ${IMAGE_NAME_BACKEND}
                        docker rm -f ${IMAGE_NAME_DB}
                        docker rm -f ${IMAGE_NAME_BACKEND}
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
                            sshagent (credentials: ['staging_ssh_credentials']) {
                                echo "Uploading Docker image to Staging"
                                      
                               sh """
                               # defining remote commands
                               ssh ${STAGING_USER}@${STAGING_IP}
                               rm -rf /home/vagrant/staging
                               mkdir /home/vagrant/staging
                               scp /home/vagrant/paymybuddy-jenkins-cicd/* ${STAGING_USER}@${STAGING_IP}:/home/vagrant/staging
                               docker rm -f production_${IMAGE_NAME_DB} || true
                               docker rm -f production_${IMAGE_NAME_BACKEND} || true
                               cd /home/vagrant/staging
                               docker compose up -d
                               """

                            }
                        
                        }
                    }
                }
                stage("Test in staging") {
                    agent any
                    steps{
                        echo "========executing Test staging========"
                        script{
                               sshagent (credentials: ['staging_ssh_credentials']) {
                              sh """
                               # defining remote commands
                               remote_cmds="
                               docker network rm paymybuddy-network 2>/dev/null || true &&
                               docker network create paymybuddy-network &&
                               docker pull ${REPOSITORY_NAME}/${IMAGE_NAME_DB}:${IMAGE_TAG} && docker pull ${REPOSITORY_NAME}/${IMAGE_NAME_BACKEND}:${IMAGE_TAG} &&
                               docker rm -f staging_${IMAGE_NAME_DB} || true &&   docker rm -f staging_${IMAGE_NAME_BACKEND} || true &&
                               docker run --name production_${IMAGE_NAME_DB} -d \
                                       --network paymybuddy-network \
                                        -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
                                        -e MYSQL_DATABASE=db_paymybuddy \
                                        -e MYSQL_USER=${MYSQL_USER} \
                                        -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
                                        -p 3306:3306 \
                                        -v db-data:/var/lib/mysql \
                                        -v ./initdb:/docker-entrypoint-initdb.d $REPOSITORY_NAME/$IMAGE_NAME_DB:$IMAGE_TAG
                               docker run --name staging_$IMAGE_NAME_BACKEND -d \
                                       --network paymybuddy-network \
                                        -e SPRING_DATASOURCE_URL=jdbc:mysql://paymybuddy-db:3306/db_paymybuddy \
                                        -e SPRING_DATASOURCE_USERNAME=${MYSQL_USER} \
                                        -e SPRING_DATASOURCE_PASSWORD=${MYSQL_PASSWORD} \
                                        -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
                                        -p 8181:8080 $REPOSITORY_NAME/$IMAGE_NAME_BACKEND:$IMAGE_TAG
                               "
                               # executing remote commands
                               ssh -o StrictHostKeyChecking=no ${STAGING_USER}@${STAGING_IP} "\$remote_cmds"
                               """
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
                            sshagent (credentials: ['ec2_ssh_credentials']) {
                                echo "Uploading Docker image to Production EC2"
                             sh """
                               # defining remote commands
                               remote_cmds="
                               docker network rm paymybuddy-network 2>/dev/null || true &&
                               docker network create paymybuddy-network &&
                               docker pull ${REPOSITORY_NAME}/${IMAGE_NAME_DB}:${IMAGE_TAG} && docker pull ${REPOSITORY_NAME}/${IMAGE_NAME_BACKEND}:${IMAGE_TAG} &&
                               docker rm -f production_${IMAGE_NAME_DB} || true &&   docker rm -f production_${IMAGE_NAME_BACKEND} || true &&
                               docker run --name production_${IMAGE_NAME_DB} -d \
                                       --network paymybuddy-network \
                                        -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
                                        -e MYSQL_DATABASE=db_paymybuddy \
                                        -e MYSQL_USER=${MYSQL_USER} \
                                        -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
                                        -p 3306:3306 \
                                        -v db-data:/var/lib/mysql \
                                        -v ./initdb:/docker-entrypoint-initdb.d $REPOSITORY_NAME/$IMAGE_NAME_DB:$IMAGE_TAG
                               docker run --name production_$IMAGE_NAME_BACKEND -d \
                                       --network paymybuddy-network \
                                        -e SPRING_DATASOURCE_URL=jdbc:mysql://paymybuddy-db:3306/db_paymybuddy \
                                        -e SPRING_DATASOURCE_USERNAME=${MYSQL_USER} \
                                        -e SPRING_DATASOURCE_PASSWORD=${MYSQL_PASSWORD} \
                                        -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
                                        -p 8181:8080 $REPOSITORY_NAME/$IMAGE_NAME_BACKEND:$IMAGE_TAG
                               "
                               # executing remote commands
                               ssh -o StrictHostKeyChecking=no ${PRODUCTION_USER}@${PRODUCTION_IP} "\$remote_cmds"
                               """

                            }
                        
                        }
                  }
               }
               stage("Test in production") {
                    agent any
                    steps{
                        echo "========executing Test staging========"
                        script{
                            sh 'curl http://${PRODUCTION_IP}:8181 | grep -q "Pay My Buddy"'
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
