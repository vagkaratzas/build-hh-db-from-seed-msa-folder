include { ARIA2            } from '../../../modules/nf-core/aria2/main'
include { SPLIT_ALIGNMENTS } from '../../../modules/local/split_alignments/main'

workflow PREPROCESS_PFAM {
    take:
    source_url
    existing_pfam_path

    main:
    ch_versions = Channel.empty()

    if (!existing_pfam_path) {
        ch_sto_gz = ARIA2( source_url ).downloaded_file
        ch_versions = ch_versions.mix( ARIA2.out.versions )
    } else {
        ch_sto_gz = Channel.of([ [ id: 'pfam_sto' ], params.existing_pfam_path ])
    }

    SPLIT_ALIGNMENTS( ch_sto_gz )
    ch_versions = ch_versions.mix( SPLIT_ALIGNMENTS.out.versions )

    emit:
    versions = ch_versions
    alignments = SPLIT_ALIGNMENTS.out.alignments
}
