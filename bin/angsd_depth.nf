process DEPTH_DIST {

    tag "${grouo.chr}"
    label 'process_low'

    input:
    tuple val(group), val(chr), path(bams), path(bais)
    tuple path(ref), path(fai)

    output:
    path "${group}.${chr}.depthGlobal", emit: global
    path "${group}.${chr}.depthSample", emit: sample
    tuple val("${task.process}"), val('angsd'), eval("angsd 2>&1 | head -1"), topic: versions

    script:
    """
    ls *.bam > ${group}.bamlist
    angsd -bam ${group}.bamlist -r ${chr} -doCounts 1 -doDepth 1 -maxDepth 4000 \\
    -minMapQ 30 -minQ 20 -baq 1 -C 50 -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \\
    -ref ${ref} -nThreads ${task.cpus} -out ${group}.${chr}
    """
}
