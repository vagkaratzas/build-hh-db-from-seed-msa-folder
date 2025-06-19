process HHSUITE_BUILDHHDB {
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
    ffindex_build -s ${prefix}_a3m.ff{data,index} tmp_aln
    mpirun -np ${task.cpus} ffindex_apply_mpi ${prefix}_a3m.ff{data,index} -i ${prefix}_hhm.ffindex -d ${prefix}_hhm.ffdata -- hhmake -i stdin -o stdout -v 0
    mpirun -np ${task.cpus} cstranslate_mpi -f -x 0.3 -c 4 -I a3m -i ${prefix}_a3m -o ${prefix}_cs219
    sort -k3 -n -r ${prefix}_cs219.ffindex | cut -f1 > sorting.dat
    ffindex_order sorting.dat ${prefix}_hhm.ff{data,index} ${prefix}_hhm_ordered.ff{data,index}
    mv ${prefix}_hhm_ordered.ffindex ${prefix}_hhm.ffindex
    mv ${prefix}_hhm_ordered.ffdata ${prefix}_hhm.ffdata
    ffindex_order sorting.dat ${prefix}_a3m.ff{data,index} ${prefix}_a3m_ordered.ff{data,index}
    mv ${prefix}_a3m_ordered.ffindex ${prefix}_a3m.ffindex
    mv ${prefix}_a3m_ordered.ffdata ${prefix}_a3m.ffdata

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
