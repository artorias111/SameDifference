process CLIP_OVERLAP {

    tag "${meta.id}"
    label 'process_low'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}.clipped.bam"), emit: bam
    path "${meta.id}.clipoverlap.txt", emit: stats
    tuple val("${task.process}"), val('bamutil'), eval("bam clipOverlap 2>&1 | grep -m 1 Version | sed 's/.*Version: //; s/;.*//'"), topic: versions

    script:
    """
    bam clipOverlap \\
        --in ${bam} \\
        --out ${meta.id}.clipped.bam \\
        --stats \\
        2> ${meta.id}.clipoverlap.txt
    """
}
