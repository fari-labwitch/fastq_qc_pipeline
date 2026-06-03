#!/usr/bin/env python3
import sys
import gzip
import json

def process_fastq(file_path):
    total_reads = 0
    total_len = 0
    gc_count = 0
    total_phred = 0

    # Open the gzipped file in text mode
    with gzip.open(file_path, 'rt') as f:
        while True:
            id_line = f.readline()
            if not id_line: 
                break # End of file
            
            seq_line = f.readline().strip()
            plus_line = f.readline()
            qual_line = f.readline().strip()

            # 1. Count Reads
            total_reads += 1
            seq_len = len(seq_line)
            total_len += seq_len
            
            # 2. GC Content
            gc_count += seq_line.count('G') + seq_line.count('C')
            
            # 3. Phred Score (ASCII to Integer)
            total_phred += sum(ord(char) - 33 for char in qual_line)

    # Prevent division by zero if file is empty
    avg_gc = (gc_count / total_len * 100) if total_len > 0 else 0
    avg_phred = (total_phred / total_len) if total_len > 0 else 0

    # Output the report
    report = {
        "total_reads_processed": total_reads,
        "average_gc_content": round(avg_gc, 2),
        "average_phred_score": round(avg_phred, 2),
        "status": "PASS" if avg_phred >= 30 else "WARN"
    }
    
    # Print to stdout so Nextflow can capture it
    print(json.dumps(report, indent=2))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: fastq_qc.py <file.fastq.gz>")
        sys.exit(1)
    process_fastq(sys.argv[1])