# Build stage
# This stage compiles the application and prepares it for deployment
# Base image with JDK for building the application
FROM eclipse-temurin:21-jdk AS builder

# Set the working directory inside the container
WORKDIR /usr/src/app/

# Copy Gradle wrapper and build files
# This includes gradlew, settings.gradle, build.gradle, and the gradle directory,
# which are necessary for building the project
COPY gradlew* settings.gradle* build.gradle /usr/src/app/
COPY ./gradle ./gradle


# Give execute permission to the Gradle wrapper and run initial Gradle tasks
RUN chmod +x ./gradlew

# 1. Download Gradle dependencies
# 2. Download necessary repositories
# These steps help in caching dependencies for faster builds in subsequent runs
RUN ./gradlew && ./gradlew downloadRepos

# Copy the rest of the application source code and protobuf files
# This includes all source files needed to build the application
COPY . .

# Build the application and install it
# The -PprotoSourceDir flag specifies the directory containing protobuf source files
RUN ./gradlew installDist -PprotoSourceDir=./pb

#####################################################
# Deployment stage
# This stage creates a lightweight image for running the application
FROM eclipse-temurin:21-jre

# Set the working directory inside the container
WORKDIR /usr/src/app/

# Create a non-root user to run the application
# This enhances security by avoiding running the application as the root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copy the built application from the builder stage
COPY --chown=appuser:appgroup --from=builder /usr/src/app/ ./

# Switch to the non-root user
USER appuser

# Expose the application port
ENV AD_PORT=9099

# Set the entry point to run the application
ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]

