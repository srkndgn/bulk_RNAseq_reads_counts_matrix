############################################################################################################################

# This is a detailed workflow to process bulk RNA-Seq reads (fastq) and generate counts matrix which can be used for various downstream analysis
# • Quality control (fastQC)
# • Trimming (Trimmomatic)
# • Alignment (HISAT2)
# • Quantification (featureCounts)

# Linux Basics
# ▸ https://ubuntu.com/tutorials/command-...
# ▸ https://xie186.github.io/Novice2Exper...
# ▸ https://hackr.io/blog/basic-linux-com...

# To Trim or to not Trim?
# ▸ https://www.ncbi.nlm.nih.gov/pmc/arti...

# Strandedness
# ▸ https://bmcgenomics.biomedcentral.com...
# ▸ https://chipster.csc.fi/manual/librar...
# ▸ http://rseqc.sourceforge.net/#infer-e...

# Data link for demo.fastq file
# https://drive.google.com/file/d/1AX-qXouF9BTeUKnqXKpk7RMBn_U08DVq/view?usp=drive_link
############################################################################################################################

# List out channels
 conda config --show channels

# List packages you have installed
 conda list --show-channel-urls

# Add the bioconda channel:
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# You can reset channel priorities by changing the order in this file: ~/.condarc
# To search for available versions of a certain package
 # conda search --help
 conda search gatk
 conda search picard
 conda search fastqc
 conda search perl
 conda search numpy

# Create two envs with different gatk, perl and picard versions
 # list envs previously created
 conda env list

############################################################################################################################

# install trimmomatic tools
# Trimmomatic: A flexible read trimming tool for Illumina NGS data
cd /path to directory/anaconda3/envs/
conda create --name trimmomatic
cd /path to directory/anaconda3/envs/trimmomatic/
conda activate trimmomatic
conda install trimmomatic
conda deactivate

############################################################################################################################
############################################################################################################################

# install hisat2 tools
# HISAT2 is a fast and sensitive alignment program for mapping next-generation sequencing reads (both DNA and RNA) to a population of human genomes as well as to a single reference genome.
cd /path to directory/anaconda3/envs/
conda create --name hisat2
cd /path to directory/anaconda3/envs/hisat2/
conda activate hisat2
conda install -c bioconda hisat2
conda deactivate

############################################################################################################################
############################################################################################################################

# install samtools
module load genomics/ngs/samtools/1.16.1/gcc-8.5.0

############################################################################################################################
############################################################################################################################

# install subread > featurecounts tools
# Subread package: high-performance read alignment, quantification and mutation discovery
cd /path to directory/anaconda3/envs/
conda create --name subread
cd /path to directory/anaconda3/envs/subread/
conda activate subread
conda install -c bioconda subread
conda deactivate

############################################################################################################################

# It is a “best practice” to avoid installing additional packages into your base software environment.

# local versions:- FastQC v0.11.9- perl 5.30.3- picard (not installed locally)
 
 conda create --name RNAseq_env1 picard=3.1.0 perl=5.34.0 fastqc=0.12.1
 
  # conda activate and deactivate envs to see envs and constitutions

 conda create --name RNAseq_env2 picard=3.0.0 perl=5.32.1 fastqc=0.11.2

 # Exporting and Sharing the environment.yml file
 # .yaml or YAML file is a language that is often used for writing configuration files.
  conda env export > ~/path to directory/anaconda3/envs/RNAseq_env2.yml

# create new env coaining same packages by using .yml file for different analysis
  conda env create --file RNAseq_env2.yml

# change working directory and put your fastq files into data folder in the working directory
cd /path to directory/RNASeq_pipeline/
mkdir data

# activate conda environment
conda activate RNAseq_env2

############################################################################################################################
############################################################################################################################

# STEP 1: Run fastqc
fastqc data/demo.fastq -o data/

# run trimmomatic to trim reads with poor quality
conda deactivate
cd /exports/humgen/Serkan/RNAseq_pipeline/data/
conda activate trimmomatic
trimmomatic SE -threads 4 demo.fastq demo_trimmed.fastq TRAILING:10 -phred33
conda deactivate
cd /path to directory/RNASeq_pipeline/

# activate conda environment
conda activate RNAseq_env2

# Run fastqc again for trimmed reads
fastqc data/demo_trimmed.fastq -o data/

############################################################################################################################
############################################################################################################################

# STEP 2: Run HISAT2 > http://daehwankimlab.github.io/hisat2/download/

mkdir HISAT2
cd HISAT2

# get the genome indices from the web page > it takes time
wget https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz

# To extract a tar.gz file, use the --extract (-x) option and specify the archive file name after the f option, print the names of the files being extracted on the terminal with -v option
tar -xvf grch38_genome.tar.gz

# run alignment
conda deactivate
cd /path to directory/RNAseq_pipeline/
conda activate hisat2
hisat2 -q --rna-strandness R -x HISAT2/grch38/genome -U data/demo_trimmed.fastq | samtools sort -o HISAT2/demo_trimmed.bam
conda deactivate
cd /path to directory/RNASeq_pipeline/

############################################################################################################################
############################################################################################################################
# STEP 3: Run featureCounts - Quantification

# activate conda environment
conda activate RNAseq_env2

# get the annotation file as gtf > https://www.ensembl.org/Homo_sapiens/Info/Index
wget http://ftp.ensembl.org/pub/release-106/gtf/homo_sapiens/Homo_sapiens.GRCh38.106.gtf.gz

# To extract a gtf.gz file, use gunzip The option used for decompressing is -d. So to unzip a file, the syntax is:
gzip -d Homo_sapiens.GRCh38.106.gtf.gz

# run featurescounts - Quantification
conda deactivate
cd /path to directory/RNAseq_pipeline/
conda activate subread
featureCounts -S 2 -a Homo_sapiens.GRCh38.106.gtf -o demo_featurecounts.txt HISAT2/demo_trimmed.bam
conda deactivate
cd /path to directory/RNASeq_pipeline/

# to check count files
cat demo_featurecounts.txt.summary
cat demo_featurecounts.txt | less

# to see just gene in and coressponding counts
cat demo_featurecounts.txt | cut -f1,7 | less

############################################################################################################################
############################################################################################################################