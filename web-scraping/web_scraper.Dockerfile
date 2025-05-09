# Use a Python base image
FROM python:3.9-slim

# Define build-time environment variables (optional)
ARG API_KEY
ARG DB_HOST
ARG DB_USER
ARG DB_PASSWORD
ARG DB_NAME
ARG JOB_NAME

# Set runtime environment variables (required)
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED 1
ENV API_KEY=${API_KEY}
ENV DB_HOST=${DB_HOST}
ENV DB_USER=${DB_USER}
ENV DB_PASSWORD=${DB_PASSWORD}
ENV DB_NAME=${DB_NAME}
ENV JOB_NAME=${JOB_NAME}

# Set the working directory inside the container
WORKDIR /app

# Install dependencies from requirements.txt
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the entire jobs directory into the container
COPY jobs /app/jobs

# Command to run the Python DAG script based on the name
CMD python /app/jobs/${JOB_NAME}
