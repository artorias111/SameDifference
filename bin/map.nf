process MAP {

    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(r1), path(r2)
    tuple val(ref_meta), path(ref_assembly), path(fai), path(dict), path(index)

    output:
    tuple val(meta), path("${meta.id}.markdup.bam"), emit: bam
    path "${meta.id}.markdup.txt", emit: markdup_stats
    tuple val("${task.process}"), val('bwa-mem2'), eval("bwa-mem2 version 2> /dev/null | tail -1"), topic: versions
    tuple val("${task.process}"), val('samtools'), eval("samtools --version | head -1 | sed 's/samtools //'"), topic: versions

    script:
    """
    bwa-mem2 mem \\
        -t ${task.cpus} \\
        -R '@RG\\tID:${meta.id}\\tSM:${meta.id}\\tLB:${meta.id}\\tPL:ILLUMINA' \\
        ${ref_assembly} ${r1} ${r2} \\
        | samtools fixmate -m -u - - \\
        | samtools sort -u -@ ${task.cpus} -m 1G -T ${meta.id}.sort - \\
        | samtools markdup -@ ${task.cpus} -d 2500 -f ${meta.id}.markdup.txt - ${meta.id}.markdup.bam
    """
}
