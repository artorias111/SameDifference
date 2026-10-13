#!/usr/bin/env nextflow

include { TRIM_READS } from './bin/fastp.nf'
include { SEQKIT_STATS } from './bin/seqkit.nf'
include { PREP_REFERENCE } from './bin/prep_reference.nf'

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
}

workflow {
    if (params.stage == 'align') {
        def reference = tuple([id: params.ref_name], file(params.ref, checkIfExists: true))
        align(params.samplesheet, reference)
    }
    else {
        error "Unknown stage '${params.stage}'. Options: align"
    }

    channel.topic('versions')
        .unique { row -> [row[1], row[2]] }
        .map { _proc, tool, version -> "${tool}\t${version}" }
        .collectFile(name: 'software_versions.tsv', storeDir: params.outdir, newLine: true, sort: true)
}
