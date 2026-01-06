# # Use the official Python image as a base image
# FROM python:3.12-slim-bookworm AS base

# # Set the working directory in the container
# WORKDIR /usr/src/app

# # Create non root user
# RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# # Copy the requirements file into the container
# COPY requirements.txt ./

# # Install deps in a virtualenv
# RUN python -m venv /venv \
#     && /venv/bin/pip install --upgrade pip \
#     && /venv/bin/pip install -r requirements.txt

# # Add venv to PATH
# ENV PATH="/venv/bin:$PATH"

# # Copy app code with correct ownership
# COPY --chown=appuser:appgroup . .

# # Install OpenTelemetry instrumentation
# RUN opentelemetry-bootstrap -a install

# # Switch to non root user
# USER appuser

# # Expose the port that the recommendation service will run on
# ENV RECOMMENDATION_PORT=1010

# # Define the command to run the recommendation service
# ENTRYPOINT ["python", "recommendation_server.py"]


FROM docker.io/library/python:3.12-alpine3.22 AS build-venv

RUN apk update && \
    apk add gcc g++ linux-headers

COPY ./src/recommendation/requirements.txt requirements.txt

RUN python -m venv venv && \
    venv/bin/pip install --no-cache-dir -r requirements.txt

RUN venv/bin/opentelemetry-bootstrap -a install

FROM docker.io/library/python:3.12-alpine3.22

COPY --from=build-venv /venv/ /venv/

WORKDIR /app

COPY ./src/recommendation/demo_pb2_grpc.py demo_pb2_grpc.py
COPY ./src/recommendation/demo_pb2.py demo_pb2.py
COPY ./src/recommendation/logger.py logger.py
COPY ./src/recommendation/metrics.py metrics.py
COPY ./src/recommendation/recommendation_server.py recommendation_server.py

EXPOSE ${RECOMMENDATION_PORT}
ENTRYPOINT [ "/venv/bin/opentelemetry-instrument", "/venv/bin/python", "recommendation_server.py" ]