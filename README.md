# FastQ QC Pipeline

A lightweight Nextflow pipeline designed for Quality Control (QC) analysis of FastQ files. This project demonstrates a production-grade, containerized bioinformatics workflow configured to run seamlessly across local operating systems (Windows, macOS, Linux).

## Project Structure

- `main.nf`: The Nextflow workflow definition.
- `nextflow.config`: Pipeline configuration, `standard` (local) execution profile.
- `bin/`: Contains the core analysis scripts (e.g., `fastq_qc.py`).
- `run.sh`: A universal wrapper script handling path conversion and Docker-out-of-Docker mounting.
- `Dockerfile`: Defines the execution environment. Includes `s5cmd` for high-speed data transfer.
- `results/`: Output directory where generated reports are stored.

---

## Part 1: Local Execution Guide

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git Bash](https://gitforwindows.org/) (if running on Windows)
> *Note: Nextflow is not required on your host machine. `run.sh` pulls and runs it via Docker.*

### 1. Build the Local Environment
The pipeline runs its processes inside a Docker container. Build it using:
```bash
docker build -t fastq-qc-env:latest .
```

### 2. Run the Pipeline
Execute the pipeline using the provided wrapper script. By default, it runs on a tiny local sample file (`raw/10k_sample.fastq.gz`) included in the repository.

```bash
./run.sh
```

### 3. Custom Input (Local, URL)
You can process your own data by providing a local path, or a remote URL path using the `--input` parameter and a custom result directory path using the `--outdir` parameter. 

```bash
# Using a remote URL
./run.sh --input "https://example.com/data.fastq.gz" --outdir "https://example.com/output/"

# Using a local file
./run.sh --input "/path/to/your/file.fastq.gz"
```

## How It Works

1. **Data Acquisition**: The pipeline fetches the target file from the provided `--input` (local path, remote URL).
2. **Quality Control**: It executes `fastq_qc.py` inside the `fastq-qc-env` container.
3. **Reporting**: Results are published to the `results/` directory (locally) or to the configured URL.


## Cross-Platform Support
The `run.sh` script is specifically engineered to handle the pathing differences between Windows (Git Bash) and Unix-like systems. It ensures that volume mounts work correctly even when launching "Docker-out-of-Docker" containers.

