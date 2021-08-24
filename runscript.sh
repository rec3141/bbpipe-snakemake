#!/bin/sh
#SBATCH --time=480:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=16G

snakemake --restart-times 3 --cores all --use-conda --keep-going --rerun-incomplete
