process INDEX_BAM {

    tag "${meta.id}"
    label 'process_low'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path(bam), path("${bam}.bai"), emit: bam
    tuple val("${task.process}"), val('samtools'), eval("samtools --version | head -1 | sed 's/samtools //'"), topic: versions

    script:
    """
    samtools index -@ ${task.cpus} ${bam}
    """
}

process SAMTOOLS_STATS {

    tag "${meta.id}"
    label 'process_low'

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    path "${meta.id}.stats.txt", emit: stats
    path "${meta.id}.flagstat.txt", emit: flagstat

    script:
    """
    samtools stats -@ ${task.cpus} ${bam} > ${meta.id}.stats.txt
    samtools flagstat -@ ${task.cpus} ${bam} > ${meta.id}.flagstat.txt
    """
}

process MOSDEPTH {

    tag "${meta.id}"
    label 'process_low'

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    path "${meta.id}.mosdepth.summary.txt", emit: summary
    path "${meta.id}.mosdepth.global.dist.txt", emit: dist
    tuple val("${task.process}"), val('mosdepth'), eval("mosdepth --version | sed 's/mosdepth //'"), topic: versions

    script:
    """
    mosdepth -n -t 4 ${meta.id} ${bam}
    """
}
