# build-hh-db-from-seed-msa-folder
Chaining HHSUITE_REFORMAT and HHSUITE_BUILDHHDB

Run with:
```
nextflow run build-hh-db-from-seed-msa-folder -profile test,singularity
```

## Mini downloaded pfam test

Run with:
```
nextflow run build-hh-db-from-seed-msa-folder -c conf/local.config -profile singularity,test_pfam_mini,local -resume
```