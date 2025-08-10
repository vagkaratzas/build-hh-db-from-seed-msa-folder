include { HHSUITE_HHBLITS } from '../../../modules/nf-core/hhsuite/hhblits/main'

workflow TEST_HHSUITE_DBS {
    take:
    msa
    hh_db

    main:
    ch_versions = Channel.empty()

    HHSUITE_HHBLITS( msa, hh_db )
    ch_versions = ch_versions.mix( HHSUITE_HHBLITS.out.versions )

    emit:
    versions = ch_versions
}
