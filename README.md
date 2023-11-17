# RNAseq Data Processing Workflow
# bulk RNAseq reads and generating counts matrix

## Overview

This repository contains a detailed workflow for processing bulk RNA-Seq reads (fastq) to generate a counts matrix for downstream analysis. The pipeline involves quality control, trimming, alignment, and quantification steps. The tools used include FastQC, Trimmomatic, HISAT2, Samtools, and featureCounts. The workflow is designed for Linux environments, and Conda is utilized for managing dependencies and environments.

## Prerequisites

Before running the pipeline, ensure that Conda is installed on your system. Additionally, make sure to set up the necessary channels and install the required packages as specified in the code.

## List out channels

> conda config --show channels

### Add the bioconda channel:

> conda config --add channels defaults

> conda config --add channels bioconda

> conda config --add channels conda-forge

## Environment Setup

Create Conda environments for the tools used in the pipeline:

- Trimmomatic
- HISAT2
- Samtools
- Subread (featureCounts)

## Execution

### Quality Control and Trimming:

#### Run FastQC for initial and trimmed reads:

> fastqc data/demo.fastq -o data/

#### Trim reads using Trimmomatic:

> conda activate trimmomatic

trimmomatic SE -threads 4 demo.fastq demo_trimmed.fastq TRAILING:10 -phred33

> conda deactivate

#### Run FastQC again for trimmed reads:

> conda activate RNAseq_env2

> fastqc data/demo_trimmed.fastq -o data/

### Alignment with HISAT2:

#### Download genome indices and perform alignment:

> conda activate hisat2

> hisat2 -q --rna-strandness R -x HISAT2/grch38/genome -U data/demo_trimmed.fastq | samtools sort -o HISAT2/demo_trimmed.bam

> conda deactivate

### Quantification with featureCounts:

#### Download the annotation file (gtf) and run featureCounts:

> conda activate subread
> featureCounts -S 2 -a Homo_sapiens.GRCh38.106.gtf -o demo_featurecounts.txt HISAT2/demo_trimmed.bam
> conda deactivate

#### Check the generated count files:

> cat demo_featurecounts.txt.summary
> cat demo_featurecounts.txt | less

#### To see only gene names and corresponding counts:

> cat demo_featurecounts.txt | cut -f1,7 | less

### Additional Information
#### Channel Configuration:

- Use conda config --show channels to list configured channels.
- Bioconda, defaults, and conda-forge channels are added for package installation.

#### Environment Export:

- The script includes instructions to export and share Conda environment specifications using .yml files.

#### Local Versions:

- Specify local versions for tools such as FastQC, Perl, and Picard during environment creation.

#### Note on Installing Packages:

- It is recommended to avoid installing additional packages into the base software environment.

### Folder Structure
- data/: Directory for storing input and output data files.
- HISAT2/: Directory for storing HISAT2 indices and output files.

### References
- https://github.com/kpatel427
