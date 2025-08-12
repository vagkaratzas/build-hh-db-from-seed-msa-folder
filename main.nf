#!/usr/bin/env nextflow

include { PREPROCESS_PFAM   } from './subworkflows/local/preprocess_pfam'
include { HHSUITE_REFORMAT  } from './modules/nf-core/hhsuite/reformat/main.nf'
include { HHSUITE_BUILDHHDB } from './modules/local/hhsuite/buildhhdb/main.nf'
include { TEST_HHSUITE_DBS  } from './subworkflows/local/test_hhsuite_dbs/'

workflow {

    ch_versions = Channel.empty()
    ch_hh_dbs   = Channel.empty()

    if (params.is_pfam) {
        ch_pfam_link = Channel.of([ [ id: 'pfam_link' ], params.pfam_link ])

        PREPROCESS_PFAM( ch_pfam_link, params.existing_pfam_path ).alignments
        ch_versions = ch_versions.mix( PREPROCESS_PFAM.out.versions )

        ch_alignments = PREPROCESS_PFAM.out.alignments
            .transpose()
            .map { meta, file ->
                [[id: file.getBaseName()], file]
            }
    } else {
        ch_alignments = Channel.fromPath(params.input, checkIfExists: true)

        ch_alignments = ch_alignments
            .map { filepath ->
                [[id: filepath.getBaseName()], file(filepath)]
            }
    }

    HHSUITE_REFORMAT( ch_alignments, "sto", "a3m" )
    ch_versions = ch_versions.mix( HHSUITE_REFORMAT.out.versions )

    ch_a3m = HHSUITE_REFORMAT.out.msa
        .map { meta, file ->
            return [file]
        }
        .collect()
        .map { file ->
            return [[id:params.db_name], file]
        }

    HHSUITE_BUILDHHDB( ch_a3m )
    ch_versions = ch_versions.mix( HHSUITE_BUILDHHDB.out.versions )

    TEST_HHSUITE_DBS( HHSUITE_REFORMAT.out.msa.first(), HHSUITE_BUILDHHDB.out.hh_db )
    ch_versions = ch_versions.mix( TEST_HHSUITE_DBS.out.versions )

    // ch_versions.view()
}
