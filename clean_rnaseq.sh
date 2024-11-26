#!/bin/bash

# Define directories for raw data and output
RAW_DATA_DIR="/WORK/Project/Gongweijun/work/smart-seq2-Homo/@颗粒细胞smart-seq/Rawdata" # Path to raw RNA-Seq data
OUTPUT_DIR="/WORK/Project/Gongweijun/work/smart-seq2-Homo/@颗粒细胞smart-seq/CleanData"  # Path to save cleaned data
ADAPTER_FILE="/WORK/Project/Gongweijun/work/smart-seq2-Homo/adapters.fa"                # Path to adapter sequence file

# Create output directory if it does not exist
mkdir -p "$OUTPUT_DIR"

# Load Trimmomatic module (if using a cluster with modules)
module load trimmomatic/0.39

# Loop through all FASTQ files in the raw data directory
for FILE in "$RAW_DATA_DIR"/*.fastq.gz; do
    # Extract base filename and prefix (without extensions)
    BASENAME=$(basename "$FILE")
    PREFIX=${BASENAME%.fastq.gz}
    
    # Define output file paths
    CLEANED_FILE="$OUTPUT_DIR/${PREFIX}_clean.fastq.gz" # Cleaned FASTQ output file
    LOG_FILE="$OUTPUT_DIR/${PREFIX}_trimming.log"      # Log file for trimming process

    echo "Processing $FILE ..." # Log progress
    
    # Run Trimmomatic for quality control and adapter trimming
    trimmomatic SE -threads 4 \                             # Single-end mode, using 4 threads
        "$FILE" "$CLEANED_FILE" \                           # Input and output file paths
        ILLUMINACLIP:"$ADAPTER_FILE":2:30:10 \              # Adapter trimming parameters
        LEADING:20 TRAILING:20 \                            # Remove low-quality bases at read ends
        SLIDINGWINDOW:4:20 MINLEN:50 > "$LOG_FILE" 2>&1     # Quality filter and minimum read length
    
    echo "Finished processing $FILE. Cleaned file saved to $CLEANED_FILE" # Log completion
done

echo "All files have been processed. Cleaned data is in $OUTPUT_DIR." # Final message
