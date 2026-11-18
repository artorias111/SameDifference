#!/usr/bin/env nextflow

include { TRIM_READS } from './bin/fastp.nf'
include { SEQKIT_STATS } from './bin/seqkit.nf'
include { PREP_REFERENCE } from './bin/prep_reference.nf'
include { MAP } from './bin/map.nf'
include { CLIP_OVERLAP } from './bin/clip_overlap.nf'
include { INDEX_BAM; SAMTOOLS_STATS; MOSDEPTH } from './bin/bam_qc.nf'
include { DEPTH_DIST } from './bin/angsd_depth.nf'

workflow align {
    take:
    samplesheet
    reference

    main:
    reads = channel.fromPath(samplesheet)
        .splitCsv(header: true)
        .map { row ->
            def meta = [id: row.sample]
            def fastq_1 = file(row.fastq_1, checkIfExists: true)
            def fastq_2 = file(row.fastq_2, checkIfExists: true)

            tuple(meta, fastq_1, fastq_2)
        }

    PREP_REFERENCE(reference)

    TRIM_READS(reads)

    trimmed = TRIM_READS.out.reads
        .map { _meta, r1, r2 -> [r1, r2] }
        .flatten()
        .collect()
    SEQKIT_STATS(trimmed)

    MAP(TRIM_READS.out.reads, PREP_REFERENCE.out.reference)
    CLIP_OVERLAP(MAP.out.bam)
    INDEX_BAM(CLIP_OVERLAP.out.bam)
    SAMTOOLS_STATS(INDEX_BAM.out.bam)
    MOSDEPTH(INDEX_BAM.out.bam)
}

workflow gl {
    take:
    bams_sheet
    chroms
    reference

    main:
    bam_ch = channel.fromPath(bams_sheet)
            .splitCsv(header: true)
            .map { row -> tuple(row.group, file(row.bam, checkIfExists: true), file("${row.bam}.bai", checkIfExists: true))}
            .groupTuple(by: 0)
            .combine(chroms)
            .map { group, bams, bais, chrom -> tuple(group, chrom, bams, bais) }

    DEPTH_DIST(bam_ch, reference)
}

workflow {
    if (params.stage == 'align') {
        def reference = tuple([id: params.ref_name], file(params.ref, checkIfExists: true))
        align(params.samplesheet, reference)
    }
    else if (params.stage == 'gl') {
        def reference = tuple(file(params.ref, checkIfExists: true), file("${params.ref}.fai", checkIfExists: true))

        chromosome_ch = channel.fromPath(params.chroms)
                    .splitText()
                    .map { chr -> chr.trim() }

        gl(params.bams, chromosome_ch, reference)
    }
    else {
        error "Unknown stage '${params.stage}'. Options: align, gl"
    }

    channel.topic('versions')
        .unique { row -> [row[1], row[2]] }
        .map { _proc, tool, version -> "${tool}\t${version}" }
        .collectFile(name: 'software_versions.tsv', storeDir: params.outdir, newLine: true, sort: true)
}
