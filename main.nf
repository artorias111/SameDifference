#!/usr/bin/env nextflow

def helpMessage() {
    log.info"""
    Usage: nextflow run artorias111/SameDifference --group1Reads /path/to/group1/reads/fq.gz --group2Reads /path/to/group2/reads/fq.gz
    """
}

if (params.help) {
    helpMessage()
    exit 0
}


// include modules

include { trim_reads as trim_group1 } from './bin/fastp.nf'

include { trim_reads as trim_group2 } from './bin/fastp.nf'

// workflow definitions

workflow { 
    reads_dir1_ch = channel.fromFilePairs("${params.group1Reads}/*{_1,_2}.fastq.gz")
    reads_dir2_ch = channel.fromFilePairs("${params.group2Reads}/*{_1,_2}.fastq.gz")

    trim_group1(reads_dir1_ch)
    trim_group2(reads_dir2_ch)

} // there's only one main workflow, for now
