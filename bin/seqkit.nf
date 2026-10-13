process SEQKIT_STATS {

    label 'process_medium'

    input:
    path reads

    output:
    path "seqkit_stats_trimmed.tsv", emit: stats
    tuple val("${task.process}"), val('seqkit'), eval("seqkit version | sed 's/seqkit v//'"), topic: versions

    script:
    """
    seqkit stats -a -T -j ${task.cpus} ${reads} > seqkit_stats_trimmed.tsv
    """
}
