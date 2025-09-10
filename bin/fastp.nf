process trim_reads { 

    conda '/data2/work/local/miniconda/envs/fastp'

    tag "trim ${untrimmed_read1.baseName.baseName}"

    input:
    tuple path(untrimmed_read1), path(untrimmed_read2)

    output:
    tuple path(trimmed_r1), path(trimmed_r2)

    script:
    // Define output and input filenames for fastp, along with the report name base

    def prefix1 = untrimmed_read1.baseName.baseName
    def prefix2 = untrimmed_read2.baseName.baseName

    def trimmed_r1 = "${prefix1}.trimmed.fastq.gz"
    def trimmed_r2 = "${prefix2}.trimmed.fastq.gz"
    def name_base = untrimmed_read1.simpleName

    """
    fastp \\
        -i ${untrimmed_read1} \\
        -I ${untrimmed_read2} \\
        -o ${trimmed_r1} \\
        -O ${trimmed_r2} \\
        -h ${name_base}.html \\
        -j ${name_base}.json
    """
