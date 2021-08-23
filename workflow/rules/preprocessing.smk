rule clump:
    input:
        f="data/{sample}_R1_001.fastq.gz",
        r="data/{sample}_R2_001.fastq.gz"
    output:
        temp("results/{sample}/clumped.fq.gz")
    log:
        "results/{sample}/logs/clump.log"
    params:
        "dedupe optical ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "clumpify.sh in1={input.f} in2={input.r} out={output} {params} t={threads} 2> {log}"

rule filter:
    input:
        "results/{sample}/clumped.fq.gz"
    output:
        temp("results/{sample}/filtered_by_tile.fq.gz")
    log:
        "results/{sample}/logs/filter.log"
    params:
        "ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "filterbytile.sh in={input} out={output} {params} t={threads} 2> {log}"

rule trim:
    input:
        "results/{sample}/filtered_by_tile.fq.gz"
    output:
        temp("results/{sample}/trimmed.fq.gz")
    log:
        "results/{sample}/logs/trim.log"
    params:
        "ktrim=r k=23 mink=11 hdist=1 tbo tpe minlen=70 ref=adapters ftm=5 ordered ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "bbduk.sh in={input} out={output} {params} t={threads} 2> {log}"

rule trim_adapters:
    input:
        "results/{sample}/trimmed.fq.gz"
    output:
        temp("results/{sample}/filtered.fq.gz")
    log:
        "results/{sample}/logs/trim_adapters.log"
    params:
        "k=31 ref=artifacts,phix entropy=.95 ordered cardinality ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "bbduk.sh in={input} out={output} {params} t={threads} 2> {log}"

rule error_correct1:
    input:
        "results/{sample}/filtered.fq.gz"
    output:
        ecco=temp("results/{sample}/ecco.fq.gz"),
        ihist="results/{sample}/ihist_merge1.txt"
    log:
        "results/{sample}/logs/error_correct1.log"
    params:
        "mix vstrict ordered ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "bbmerge.sh in={input} out={output.ecco} {params} ihist={output.ihist} t={threads} 2> {log}"

rule error_correct2:
    input:
        "results/{sample}/ecco.fq.gz"
    output:
        temp("results/{sample}/eccc.fq.gz")
    log:
        "results/{sample}/logs/error_correct2.log"
    params:
        "ecc passes=4 reorder ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "clumpify.sh in={input} out={output} {params} t={threads} 2> {log}"

rule error_correct3:
    input:
        "results/{sample}/eccc.fq.gz"
    output:
        "results/{sample}/ecct.fq.gz"
    log:
        "results/{sample}/logs/error_correct3.log"
    params:
        "ecc k=62 ordered ow=t prefilter=2"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "tadpole.sh in={input} out={output} {params} t={threads} 2> {log}"
    
rule normalize:
    input:
        "results/{sample}/ecct.fq.gz"
    output:
        norm=temp("results/{sample}/normalized.fq.gz"),
        hist="results/{sample}/hkist.txt",
        peaks="results/{sample}/peaks.txt"
    log:
        "results/{sample}/logs/normalize.log"
    params:
        "target=100 mindepth=2 prefilter=t ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "bbnorm.sh in={input} out={output.norm} {params} hist={output.hist} peaks={output.peaks} t={threads} 2> {log}"

rule merge:
    input:
        "results/{sample}/normalized.fq.gz"
    output:
        m=temp("results/{sample}/merged.fq.gz"),
        u=temp("results/{sample}/unmerged.fq.gz"),
        ihist="results/{sample}/ihist_merge.txt"
    log:
        "results/{sample}/logs/merge.log"
    params:
        "strict k=93 extend2=80 rem ordered ow=t prefilter=2"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "bbmerge-auto.sh in={input} out={output.m} outu={output.u} {params} ihist={output.ihist} t={threads} 2> {log}"

rule qtrim:
    input:
        "results/{sample}/unmerged.fq.gz"
    output:
        temp("results/{sample}/qtrimmed.fq.gz")
    log:
        "results/{sample}/logs/qtrim.log"
    params:
        "qtrim=r trimq=10 minlen=70 ordered ow=t"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        "bbduk.sh in={input} out={output} {params} t={threads} 2> {log}"
