include { ARIA2 } from '../../../modules/nf-core/aria2/main'

workflow PREPROCESS_PFAM {
    take:
    source_url

    main:
    ch_versions = Channel.empty()

    ARIA2( source_url )
    ch_versions = ch_versions.mix( ARIA2.out.versions )

    emit:
    versions = ch_versions
}
