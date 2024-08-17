# build-hh-db-from-seed-msa-folder
Chaining HHSUITE_REFORMAT and HHSUITE_BUILDHHDB

Run with
```
slurm:
NXF_VER=24.04.1 nextflow run main.nf -profile slurm,conda,singularity
local:
NXF_VER=24.04.1 nextflow run main.nf -profile test_local,conda,singularity
```
