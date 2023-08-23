# First stage: Build stage
FROM maven:3.8.1-openjdk-17-slim AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src/ /app/src/
RUN mvn package -DskipTests

# Extract the application name from pom.xml
#RUN mvn help:evaluate -Dexpression=project.name -q -DforceStdout > /tmp/appname.txt || echo "BezKoder" > /tmp/appname.txt
RUN echo $(mvn help:evaluate -Dexpression=project.name -q -DforceStdout)-$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout) > /tmp/appname.txt || echo "PetClinic-0.0.1" > /tmp/appname.txt


# Second stage: Run stage
FROM openjdk:17.0.1-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar ./
COPY --from=build /tmp/appname.txt ./appname.txt

# Create /var/log/bezkoder directory with full permissions
RUN mkdir -p /var/log/petclinic && chmod 777 /var/log/petclinic

EXPOSE 8080

CMD ["sh", "-c", "java -jar $(cat appname.txt).jar"]
