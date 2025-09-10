process trim_reads { 

    conda params.fastp_env

    tag "trim ${sample_id}"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}*.trimmed.fastq.gz")
    path "${sample_id}.html", emit: html_report
    path "${sample_id}.json", emit: json_report


    script:
    // Define output and input filenames for fastp, along with the report name base

    def untrimmed_read1 = reads[0]
    def untrimmed_read2 = reads[1]

    def name_base = sample_id
    """
    fastp \\
        -i ${untrimmed_read1} \\
        -I ${untrimmed_read2} \\
        -o ${sample_id}_1.trimmed.fastq.gz \\
        -O ${sample_id}_2.trimmed.fastq.gz \\
        -h ${name_base}.html \\
        -j ${name_base}.json
    """
}
