#!/bin/bash
# ==============================================================================
# run.sh - Universal Nextflow Wrapper (Windows / Mac / Linux)
# ==============================================================================
# This script spins up the Nextflow orchestrator inside a Docker container.
# It automatically detects if you are running it on a Windows machine (via Git Bash)
# or a native Unix machine (Mac/Linux/WSL) and adjusts the file paths accordingly
# to prevent the dreaded "Docker-out-of-Docker" pathing bugs.
# ==============================================================================

echo "Starting Nextflow Pipeline..."

# ------------------------------------------------------------------------------
# STEP 1: Detect the Operating System
# ------------------------------------------------------------------------------
# 'uname -s' returns the kernel name. 
# Mac returns 'Darwin', Linux returns 'Linux'.
# Windows Git Bash returns something like 'MINGW64_NT-10.0' or 'MSYS_NT'.
OS="$(uname -s)"

# ------------------------------------------------------------------------------
# STEP 2: Configure Environment-Specific Paths
# ------------------------------------------------------------------------------
if [[ "${OS}" == *"MINGW"* ]] || [[ "${OS}" == *"MSYS"* ]]; then
    # --- WINDOWS (GIT BASH) CONFIGURATION ---
    
    # 1. Stop Git Bash from trying to be helpful. It normally auto-converts 
    #    Linux paths (/var/run...) into Windows paths (C:\var\run...). 
    #    Docker Desktop hates this. This flag disables that conversion.
    export MSYS_NO_PATHCONV=1
    
    # 2. To pass an absolute Linux path to Docker on Windows without Git Bash 
    #    mangling it, we must prepend it with a double slash (//).
    DOCKER_SOCK="//var/run/docker.sock"
    
    # 3. We must mount the exact current directory ($PWD) to the exact same 
    #    path inside the container. This ensures that when Nextflow tells the 
    #    Python worker container where the files are, both the host and the 
    #    worker agree on the path name.
    MOUNT_PATH="//$PWD://$PWD"
    WORK_PATH="//$PWD"

    echo "Windows/Git Bash environment detected. Applying path fixes."

else
    # --- MAC / LINUX / WSL CONFIGURATION ---
    
    # Native Unix environments don't need double slashes or path conversion hacks.
    DOCKER_SOCK="/var/run/docker.sock"
    MOUNT_PATH="$PWD:$PWD"
    WORK_PATH="$PWD"
    
    echo "Unix environment detected. Using standard paths."
fi

# ------------------------------------------------------------------------------
# STEP 3: Version Control & Image Pull
# ------------------------------------------------------------------------------
# We pin the Nextflow version. In a company setting, you never use 'latest' 
# because if the pipeline breaks 6 months from now, you need to know exactly 
# which version of the engine was running it today.
NEXTFLOW_IMAGE="nextflow/nextflow:26.04.3"

echo "Pulling Nextflow image to ensure it's up to date..."
docker pull $NEXTFLOW_IMAGE

# ------------------------------------------------------------------------------
# STEP 4: Execution
# ------------------------------------------------------------------------------
# We create the logs directory first, otherwise Nextflow might crash trying
# to write a log file into a folder that doesn't exist yet.
# Note the order: nextflow [GLOBAL_FLAGS] run [RUN_FLAGS]
# 
# --rm  : Deletes the Nextflow container after it finishes (saves disk space).
# -v    : Mounts the Docker socket (allows Nextflow to spin up sibling containers).
# -v    : Mounts your project files into the container.
# -w    : Sets the starting directory inside the container to your project folder.
# -log  : Puts the messy orchestrator logs into a dedicated folder.
# "$@"  : Passes any extra flags you type (like -resume) directly to Nextflow.

mkdir -p logs

docker run --rm \
  -v ${DOCKER_SOCK}:${DOCKER_SOCK} \
  -v "${MOUNT_PATH}" \
  -w "${WORK_PATH}" \
  $NEXTFLOW_IMAGE nextflow -log logs/.nextflow.log run main.nf "$@"