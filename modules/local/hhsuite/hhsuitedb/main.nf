process HHSUITE_HHSUITEDB {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/microbiome-informatics/hh-suite-db-builder:1.0.0"

    input:
    tuple val(meta), path(a3m, stageAs: 'tmp_aln/*')

    output:
    tuple val(meta), path("${prefix}"), emit: hh_db
    path "versions.yml"               , emit: 'versions'

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    hhsuitedb.py \\
        --ia3m ${a3m}/*.a3m \\
        -o ${prefix} \\
        --cpu $task.cpus

    mkdir -p ${prefix}
    mv ${prefix}_* ${prefix}/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hh-suite: \$(hhblits -h | grep 'HHblits' | sed -n -e 's/.*\\([0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\).*/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${prefix}
    touch ${prefix}/${prefix}_a3m_a3m.ffdata
    touch ${prefix}/${prefix}_a3m_a3m.ffindex
    touch ${prefix}/${prefix}_a3m_cs219.ffdata
    touch ${prefix}/${prefix}_a3m_cs219.ffindex
    touch ${prefix}/${prefix}_a3m_cs219.log1
    touch ${prefix}/${prefix}_a3m_hmm.ffdata
    touch ${prefix}/${prefix}_a3m_hmm.ffindex

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hh-suite: \$(hhblits -h | grep 'HHblits' | sed -n -e 's/.*\\([0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\).*/\\1/p')
    END_VERSIONS
    """
}
