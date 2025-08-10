include { ARIA2            } from '../../../modules/nf-core/aria2/main'
include { SPLIT_ALIGNMENTS } from '../../../modules/local/split_alignments/main'

workflow PREPROCESS_PFAM {
    take:
    source_url

    main:
    ch_versions = Channel.empty()

    ARIA2( source_url )
    ch_versions = ch_versions.mix( ARIA2.out.versions )

    SPLIT_ALIGNMENTS( ARIA2.out.downloaded_file )
    ch_versions = ch_versions.mix( SPLIT_ALIGNMENTS.out.versions )

    emit:
    versions = ch_versions
    alignments = SPLIT_ALIGNMENTS.out.alignments
}
