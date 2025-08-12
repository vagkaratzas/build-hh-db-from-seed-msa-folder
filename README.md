# build-hh-db-from-seed-msa-folder
Building an HH-suite formatted database, starting from MSA files.
If a url to `Pfam-A.seed.gz` is provided in `pfam_link` and `is_pfam` is set to `True`,
then the pipeline will automatically split the seed alignments in their respective folders,
before reformatting them to `a3m` and building the HH database.
Finally, `hhsuite/hhblits` is run against the generated hh-db to identify any potential errors.

Test with:
```
nextflow run build-hh-db-from-seed-msa-folder -profile test,singularity
```

## Mini downloaded pfam test

Test with:
```
nextflow run build-hh-db-from-seed-msa-folder -c conf/local.config -profile singularity,test_pfam_mini,local -resume
```