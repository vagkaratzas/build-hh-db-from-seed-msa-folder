# build-hh-db-from-seed-msa-folder
Chaining HHSUITE_REFORMAT and HHSUITE_BUILDHHDB

Run with
```
slurm:
nextflow run main.nf -profile slurm,conda,singularity
local:
nextflow run main.nf -profile test_local,conda,singularity
```
