process PREP_REFERENCE {

    tag "${meta.id}"
    label 'process_high'

    input:
    tuple val(meta), path(ref_assembly)

    output:
    tuple val(meta), path(ref_assembly), path("${ref_assembly}.fai"), path("${ref_assembly.baseName}.dict"), path("${ref_assembly}.{0123,amb,ann,bwt.2bit.64,pac}"), emit: reference
    tuple val("${task.process}"), val('bwa-mem2'), eval("bwa-mem2 version 2> /dev/null | tail -1"), topic: versions
    tuple val("${task.process}"), val('samtools'), eval("samtools --version | head -1 | sed 's/samtools //'"), topic: versions

    script:
    """
    bwa-mem2 index ${ref_assembly}
    samtools faidx ${ref_assembly}
    samtools dict ${ref_assembly} -o ${ref_assembly.baseName}.dict
    """
}
