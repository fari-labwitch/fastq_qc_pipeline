# Use a lightweight official Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies required by Nextflow
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    gzip \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Install s5cmd (nextflow uses thisfor high-speed data transfer)
RUN curl -L https://github.com/peak/s5cmd/releases/download/v2.2.2/s5cmd_2.2.2_Linux-64bit.tar.gz | tar -xz && \
    mv s5cmd /usr/local/bin/ && \
    rm CHANGELOG.md LICENSE README.md

# In a standard setup, we would COPY requirements.txt here.
# For this script, the standard library is sufficient.
# Note: We do NOT copy fastq_qc.py here. Nextflow automatically mounts it!