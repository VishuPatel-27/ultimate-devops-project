# Dockerfile for Product Catalog Service (Build Stage)
# Use official Golang image as the build environment
FROM golang:1.22-alpine AS builder

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy go.mod and go.sum files to the working directory
COPY go.mod go.sum ./

# Download Go module dependencies
RUN go mod download

# Copy the entire project into the container
COPY . .

# Build the Product Catalog service and store the binary in the product-catalog directory
RUN go build -o product-catalog .

# Release Stage
# Use a minimal Alpine Linux image for the final container
# This keeps the final image small and secure
FROM alpine AS release

# Set the working directory inside the container
WORKDIR /usr/src/app

# Create a group and a user (alphine uses addgroup and adduser commands)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy binary with correct ownership
COPY --chown=appuser:appgroup --from=builder /usr/src/app/product-catalog ./product-catalog

# Copy products directory
COPY --chown=appuser:appgroup ./products ./products

# Tell Docker to use this user for everything following
USER appuser

# Expose the port that the Product Catalog service will run on
ENV PRODUCT_CATALOG_PORT=8088

# Define the entry point to run the Product Catalog service
ENTRYPOINT [ "./product-catalog" ]