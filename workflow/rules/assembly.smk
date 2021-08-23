rule repair:
    input:
        "results/{sample}/qtrimmed.fq.gz"
    output:
        temp("results/{sample}/qtrimmed_repaired.fq.gz")
    log:
        "results/{sample}/logs/repair.log"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "repair.sh in={input} out={output} repair 2> {log}"

rule spades:
    input:
        merged="results/{sample}/merged.fq.gz",
        qtrimmed="results/{sample}/qtrimmed_repaired.fq.gz"
    output:
        spades_dir=directory("results/{sample}/spades_out"),
        contigs="results/{sample}/spades_out/contigs.fasta"
    log:
        "results/{sample}/logs/spades.log"
    conda:
        "../envs/spades.yaml"
    params:
        init="-k 25,55,95,125 --phred-offset 33",
        final="--only-assembler --meta --mem 3000"
    threads: 12
    shell:
        """
        if [ -e "{output.spades_dir}/spades.log" ]; then
        spades.py -o {output.spades_dir} --continue >> {log}
        else
        spades.py {params.init} -s {input.merged} --12 {input.qtrimmed} -o {output.spades_dir} {params.final} > {log}
        fi
        """

rule megahit:
    input:
        merged="results/{sample}/merged.fq.gz",
        qtrimmed="results/{sample}/qtrimmed_repaired.fq.gz"
    output:
        megahit_dir=directory("results/{sample}/megahit_out"),
        contigs="results/{sample}/megahit_out/final.contigs.fa"
    log:
        "results/{sample}/logs/megahit.log"
    conda:
        "../envs/megahit.yaml"
    params:
        "--k-min 45 --k-max 225 --k-step 26 --min-count 2"
    threads: 12
    shell:
        """
        rmdir {output.megahit_dir}
        megahit {params} -r {input.merged} --12 {input.qtrimmed} -o {output.megahit_dir} 2> {log}
        """

rule dedupe:
    input:
        s="results/{sample}/spades_out/contigs.fasta",
        m="results/{sample}/megahit_out/final.contigs.fa"
    output:
        s1="results/{sample}/spades_dedupe100.fasta.gz",
        s2="results/{sample}/spades_dedupe99.fasta.gz",
        s3="results/{sample}/spades_dedupe98.fasta",
        m1="results/{sample}/megahit_dedupe100.fasta.gz",
        m2="results/{sample}/megahit_dedupe99.fasta.gz",
        m3="results/{sample}/megahit_dedupe98.fasta"
    log:
        s="results/{sample}/logs/dedupe_spades.log",
        m="results/{sample}/logs/dedupe_megahit.log"
    conda:
        "../envs/bbtools.yaml"
    params:
        "sort=length uniquenames=t minidentity="
    threads: 12
    shell:
        """
        dedupe.sh {params}100 in={input.s} out={output.s1} t={threads} 2> {log.s}
        dedupe.sh {params}99 in={output.s1} out={output.s2} t={threads} 2>> {log.s}
        dedupe.sh {params}98 in={output.s2} out={output.s3} t={threads} 2>> {log.s}

        dedupe.sh {params}100 in={input.m} out={output.m1} t={threads} 2> {log.m}
        dedupe.sh {params}99 in={output.m1} out={output.m2} t={threads} 2>> {log.m}
        dedupe.sh {params}98 in={output.m2} out={output.m3} t={threads} 2>> {log.m}
        """
