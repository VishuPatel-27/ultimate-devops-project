# Use the official Python image as a base image
FROM python:3.12-slim-bookworm AS base

# Set the working directory in the container
WORKDIR /usr/src/app

# Create non root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copy the requirements file into the container
COPY requirements.txt ./

# Install deps in a virtualenv
RUN python -m venv /venv \
    && /venv/bin/pip install --upgrade pip \
    && /venv/bin/pip install -r requirements.txt

# Add venv to PATH
ENV PATH="/venv/bin:$PATH"

# Copy app code with correct ownership
COPY --chown=appuser:appgroup . .

# Install OpenTelemetry instrumentation
RUN opentelemetry-bootstrap -a install

# Switch to non root user
USER appuser

# Expose the port that the recommendation service will run on
ENV RECOMMENDATION_PORT=1010

# Define the command to run the recommendation service
ENTRYPOINT ["python", "recommendation_server.py"]
