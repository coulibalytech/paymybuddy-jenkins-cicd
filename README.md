
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
- **Registry_backend:** Backend service of private docker registry
- **Registry_frontend:** Frontend service of private docker registry to manage docker image

---

### How to use it ?:


1. **Preparation of host machine: ( you can use another methode to build your host vm)**
   - From your terminal, use the following commands to build your host machin via vagrant  :
      cd /build-host-vm
      buil-host-vm> vagrant up
   - After connect in your host via SSH-REMOTE VScode or MobaXtrem (host-ip/password(vangrant))

2. **Clone this repository in your local repository:**
   - From your terminal run this commande to clone : git clone https://github.com/coulibalytech/paymybuddy.git
   - cd /paymybuddy
   - paymybuddy>
   
3. **Deploy both 4 via Docker-compose:**
   - docker compose up -d --build
   **![Docker compose resultat](/screenshots/lance-commande-docker-compose.png)**

4. **Test Paymybuddy application:**
   - Access the frontend of application webbrowser
   **![Access to application via webrowser](/screenshots/Lancement-application-Paymybuddy.png)**
   **![Create user count](/screenshots/Creation-compte-utilisateur.png)**
   **![Connec to user count](/screenshots/Creation-compte-utilisateur-2.png)**
   **![Connec to user count](/screenshots/Creation-compte-utilisateur-2.png)**

5. **Deployment to Docker registry :**
   - Create docker images of paymybuddy-backend and paymybuddy-db
   **![Docker images of paymybuddy-db](/screenshots/capture-image-container-paymybuddy-db.png)**
   **![Docker images of paymybuddy-backend](/screenshots/capture-image-container-paymybuddy-backend.png)**
   **![Check version tag](/screenshots/version-tag-local-paymybuddy.png)**
   **![Deployment in docker registry](/screenshots/Push-images-registry-preivee.png)**

6. **Check docker image in gui of registry :**
 **![List of docker image](/screenshots/GUI-REGSITRY-PAYMYBUDDY.png)**
   

