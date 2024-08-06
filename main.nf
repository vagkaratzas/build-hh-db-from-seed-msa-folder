#!/usr/bin/env nextflow

include { HHSUITE_REFORMAT  } from "./modules/nf-core/hhsuite/reformat/main.nf"
include { HHSUITE_BUILDHHDB } from "./modules/nf-core/hhsuite/buildhhdb/main.nf"

workflow {
    seed_msa_sto_dir = channel.fromPath(params.input)
    seed_msa_sto_dir
        .map { filepath ->
            return [ [id:"mgnifams_hh_db"], file(filepath) ]
        }
        .set { seed_msa_sto_dir }

    a3m_ch    = HHSUITE_REFORMAT(seed_msa_sto_dir, "sto", "a3m").fa
    hh_db_ch  = HHSUITE_BUILDHHDB(a3m_ch).hh_db
}
