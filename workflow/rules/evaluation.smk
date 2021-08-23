rule stats:
    input:
        spades="results/{sample}/spades_out/contigs.fasta",
        megahit="results/{sample}/megahit_out/final.contigs.fa",
        dedupe_spades="results/{sample}/spades_dedupe98.fasta",
        dedupe_megahit="results/{sample}/megahit_dedupe98.fasta"
    output:
        spades="results/{sample}/assembly_stats_spades.txt",
        megahit="results/{sample}/assembly_stats_megahit.txt"
    log:
        "results/{sample}/logs/stats.log"
    conda:
        "../envs/bbtools.yaml"
    threads: 12
    shell:
        """
        statswrapper.sh {input.spades} {input.dedupe_spades} format=3 out={output.spades} t={threads} 2> {log}
        statswrapper.sh {input.megahit} {input.dedupe_megahit} format=3 out={output.megahit} t={threads} 2>> {log}
        """

rule calculate_coverage:
    input:
        i="results/{sample}/filtered.fq.gz",
        ref_spades="results/{sample}/spades_dedupe98.fasta",
        ref_megahit="results/{sample}/megahit_dedupe98.fasta"
    output:
        covhist_spades="results/{sample}/covhist_spades.txt",
        covstats_spades="results/{sample}/covstats_spades.txt",
        covhist_megahit="results/{sample}/covhist_megahit.txt",
        covstats_megahit="results/{sample}/covstats_megahit.txt"
    log:
        "results/{sample}/logs/calculate_coverage.log"
    conda:
        "../envs/bbtools.yaml"
    params:
        "nodisk maxindel=200 minid=90 qtrim=10 untrim ambig=all"
    threads: 12
    shell:
        """
        bbmap.sh in={input.i} ref={input.ref_spades} {params} covhist={output.covhist_spades} covstats={output.covstats_spades} t={threads} 2> {log}
        bbmap.sh in={input.i} ref={input.ref_megahit} {params} covhist={output.covhist_megahit} covstats={output.covstats_megahit} t={threads} 2>> {log}
        """
