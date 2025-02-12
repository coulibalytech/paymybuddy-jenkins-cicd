# Use Amazon Corretto base image with Java 17 on Alpine Linux
FROM amazoncorretto:17-alpine

RUN apk add --no-cache bash

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file from the local machine to the container
COPY ./target/paymybuddy.jar paymybuddy.jar


# Expose the application port (in this case, port 8080)
EXPOSE 8080

# Command to run the JAR file
ENTRYPOINT ["java", "-jar", "/app/paymybuddy.jar"]
