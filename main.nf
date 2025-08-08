#!/usr/bin/env nextflow

include { PREPROCESS_PFAM   } from './subworkflows/local/preprocess_pfam/main.nf'
include { HHSUITE_REFORMAT  } from './modules/nf-core/hhsuite/reformat/main.nf'
include { HHSUITE_BUILDHHDB } from './modules/local/hhsuite/buildhhdb/main.nf'
include { HHSUITE_HHSUITEDB } from './modules/local/hhsuite/hhsuitedb/main.nf'

workflow {
    def counter = 0

    if (params.is_pfam) {
        ch_pfam_link = Channel.of([ [ id: 'pfam_link' ], params.pfam_link ])
        PREPROCESS_PFAM( ch_pfam_link )
    }
    // seed_msa_sto_dir = channel.fromPath(params.input)
    // seed_msa_sto_dir
    //     .map { filepath ->
    //         counter += 1
    //         return [[id: "aln_${counter}"], file(filepath)]
    //     }
    //     .set { seed_msa_sto_dir }

    // a3m_ch    = HHSUITE_REFORMAT( seed_msa_sto_dir, "sto", "a3m" ).msa
    // a3m_ch = a3m_ch.map { meta, file ->
    //         return [file]
    //     }.collect()
    //     .map { file ->
    //         return [[id:params.db_name], file]
    //     }
    // // HHSUITE_BUILDHHDB( a3m_ch )
    // HHSUITE_HHSUITEDB( a3m_ch )
}
