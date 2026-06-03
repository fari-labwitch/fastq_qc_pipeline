// ==============================================================================
// main.nf - Quality Control Pipeline
// ==============================================================================

// ==============================================================================
// 1. Pipeline Parameters
// ==============================================================================

// Set default local paths
// Each parameter can be overwritten using --{parameter_name} {value} .e.g --input "raw_files/test_file.fastq.gz" --outdir "my_results"
params.input = "raw/10k_sample.fastq.gz"
params.outdir = "results"

// ==============================================================================
// 2. Define Processes
// ==============================================================================

process RUN_QC {
    // This tells Nextflow to copy anything in 'output' to the 'results' folder
    publishDir params.outdir, mode: 'copy'

    // Define inputs/outputs
    input:
    path raw_fastq

    output:
    path "qc_report.json"

    // The script to run inside the Docker container
    // Because fastq_qc.py is in the bin/ folder, Nextflow automatically 
    // makes it available in the container's path.
    script:
    """
    fastq_qc.py ${raw_fastq} > qc_report.json
    """
}

// ==============================================================================
// 3. Define Workflow
// ==============================================================================

workflow {
    // Create an asynchronous data stream from the input parameter
    fastq_channel = Channel.fromPath(params.input)

    // Run the process and print the output file path
    qc_results = RUN_QC(fastq_channel)
    
    // View the contents of the generated JSON
    qc_results.view { report -> "Report generated at: ${report}\nContents:\n${report.text}" }
}