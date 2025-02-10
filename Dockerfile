#Use mysql 8 image
FROM mysql:8.0 AS paymybuddy-db
# Environement variable
ENV  MYSQL_ROOT_PASSWORD$={MYSQL_ROOT_PASSWORD} \
     MYSQL_DATABASE=db_paymybuddy \
     MYSQL_USER=${MYSQL_USER} \
     MYSQL_PASSWORD=${MYSQL_PASSWORD}
# Expose the application port
EXPOSE 3306
# Volume 
COPY ./initdb /docker-entrypoint-initdb.d

# Use Amazon Corretto base image with Java 17 on Alpine Linux
FROM amazoncorretto:17-alpine AS paymybuddy-backend
RUN apk add --no-cache bash
# Set the working directory inside the container
WORKDIR /app
# Copy the JAR file from the local machine to the container
COPY ./target/paymybuddy.jar paymybuddy.jar
# Env variable
ENV  SPRING_DATASOURCE_URL=jdbc:mysql://paymybuddy-db:3306/db_paymybuddy \
     SPRING_DATASOURCE_USERNAME=${MYSQL_USER}
     SPRING_DATASOURCE_PASSWORD=${MYSQL_PASSWORD}
# Expose the application port (in this case, port 8080)
EXPOSE 8080
# Command to run the JAR file
ENTRYPOINT ["java", "-jar", "/app/paymybuddy.jar"]

