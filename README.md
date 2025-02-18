
# PayMyBuddy - Financial Transaction Application - Jenkins CI/CD

This repository contains the *PayMyBuddy* application, which allows users to manage financial transactions. It includes a Spring Boot backend and MySQL database.

**![PayMyBuddy Overview](https://lh7-rt.googleusercontent.com/docsz/AD_4nXf0fGeMjotdY0KzJL13cmGhXad3GM_kn7OSXZJ4CCSQ89zZTlrhBVVi91QjRMgVeszmUMAMAgyavzr4VyQ9YOAUiWmL2sF6aVQYiJPLZfztxv7ERNsIra2O_2SYIX5ZFY5eOARMeI2qnOwrIymuyJnvtuYs?key=mLqAl_ccMoG4hHcRzSYKpw)**

---

## Objectives

This POC demonstrates the deployment of the *PayMyBuddy* app using Docker containers, with a focus on:

- Improving deployment processes
- Versioning infrastructure releases
- Implementing best practices for Docker
- Using Infrastructure as Code
- Creat CI/CD Pipeline with Jenkins
- Check Quality of Code with SonarCloud

## **Steps of the CI/CD Pipeline Jenkins**

The pipeline must include the following steps, and the steps must be executed with a Docker-based agent:

1. **Automated Tests**  
   Execution of unit tests and integration tests.

2. **Code Quality Verification**  
   Static code analysis to comply with quality standards using SonarCloud.

3. **Build and Packaging**  
   Generation of the compiled application file from the source code, building the image, and pushing the image to DockerHub.

4. **Staging**  
   Deployment in a pre-production environment.

5. **Production**  
   Final deployment in the production environment.

6. **Deployment Validation Tests**  
   Verification that the deployment was successful and that the application works as expected.

### Key Themes:

- Dockerization of the backend and database
- Orchestration with Docker Compose
- Securing the deployment process
- Deploying and managing Docker images via DockerHub
- Check Quality of Code with SonarCloud

---

## Context

*PayMyBuddy* is an application for managing financial transactions between friends. The current infrastructure is tightly coupled and manually deployed, resulting in inefficiencies. We aim to improve scalability and streamline the deployment process using Docker and container orchestration.

---

## Infrastructure

The infrastructure will run on a Docker-enabled server with **Ubuntu 20.04**. This proof-of-concept (POC) includes containerizing the Spring Boot backend and MySQL database and automating deployment using Docker Compose.

### Components:

- **Dockerfile:** To build docker image of paymybuddy-backend
- **Docker-compose:** To build and run of the 4 services (Paymybuddy-backend,Paymybuddy-db,Registry_backend and Registry_frontend )

- **Paymybuddy-backend:** Service to manages user data and transactions
- **Paymybuddy-db:** Database service to stores users, transactions, and account details
- Repository github jenkins cicd

---

### How to use it ? (Pipeline CI CD JENKINS FOR PAYMYBUDDY IN 12 STAGES):


1. **Stage 1:  Check out from version control**
   - Control version repository of project  :
     **![Check out from version control](/screenshots/stage1-Checkoutfromversioncontrol.png)**

2. **Stage 2: Building Docker images (DB + Backend) via Docker compose:**
   - Commmande docker compose builds the docker images of paymybuddy-db and paymybuddy-backend
     **![Build DB and Backend images](/screenshots/Stage2-Build-Docker-image-BD-BAKCEND.png)**
     
3. **Stage 3: Test Docker Images**
   - Test paymybuddy-db image
   **![Testing database availability on 3306](/screenshots/Stage-3-Test-database.png)**
     
    - Test paymybuddy-backend image
   **![Testing database availability on 3306](/screenshots/Stage-3-Test-backend.png)**

4. **Stage 4: SonarCloud Analysis**
   - Test SonarCloud Analysis
     **![SonarCloud Analysis](/screenshots/Stage4-Test-sonarcloud.png)**
     
5. **Stage 5: Push Images(DB & Backend) in docker hub**
   - Push Images(DB & Backend) in docker hub
   **![Push Images(DB & Backend) in docker hub](/screenshots/Stage-5-Test-PushInDockhub.png)**
   - View of docker images in DockerHub
      **![DockerHub](/screenshots/DeploymenttoDockerhub.png)**

6. **Stage 6: Clean container**
   - Clean container after test
   **![Clean container](/screenshots/Stage-6-CleanContainer.png)**

7. **Stage 7: Deploy in staging**
   - Deploy in staging application paymybuddy
   **![Clean container](/screenshots/Stage-7-DeployStaging.png)**

8. **Stage 8: Test in staging**
   - Test application in staging environement
   **![Clean container](/screenshots/Stage-8-Test-in-staging.png)**

9. **Stage 9: Deploy in production**
   - Deploy in production application paymybuddy
   **![Clean container](/screenshots/Stage-9-Deploy-in-production.png)**

10. **Stage 10: Test in production**
   - Test application in production environement
   **![Clean container](/screenshots/Stage-10-Test-in-production.png)**
     

11. **Manual Test Paymybuddy application:**
   - Access the frontend of application webbrowser
   **![Access to application via webrowser](/screenshots/Lancement-application-Paymybuddy.png)**
   **![Create user count](/screenshots/Creation-compte-utilisateur.png)**
   **![Connec to user count](/screenshots/Creation-compte-utilisateur-2.png)**
   **![Connec to user count](/screenshots/Creation-compte-utilisateur-2.png)**

12. **Stage 10: Slack notification of jobs pipeline**
   - Send the result of job via Slack notification
   **![Slack notification](/screenshots/Stage-12-SlackNotifcation.png)**
   **![Slack](/screenshots/Stage-13-SlackNotifcation.png)**




   

