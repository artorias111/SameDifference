process TRIM_READS {

    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}_1.trimmed.fastq.gz"), path("${meta.id}_2.trimmed.fastq.gz"), emit: reads
    path "${meta.id}.fastp.json", emit: json
    path "${meta.id}.fastp.html", emit: html
    tuple val("${task.process}"), val('fastp'), eval("fastp --version 2>&1 | sed 's/fastp //'"), topic: versions

    script:
    """
    fastp \\
        -i ${r1} \\
        -I ${r2} \\
        -o ${meta.id}_1.trimmed.fastq.gz \\
        -O ${meta.id}_2.trimmed.fastq.gz \\
        --detect_adapter_for_pe \\
        --trim_poly_g \\
        --length_required 35 \\
        -w ${task.cpus} \\
        -j ${meta.id}.fastp.json \\
        -h ${meta.id}.fastp.html
    """
}
