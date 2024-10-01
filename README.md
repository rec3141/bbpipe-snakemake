This package conducts quality control, assembly, mapping, and binning of Illumina metagenomic data using a Snakemake workflow.

# bbpipe

Make sure that you put the data you want to use in `./data` before running. 
Results will appear in `./results`.

## To run

```sh
snakemake --cores [number of threads to use] --use-conda
```

## To schedule with Slurm as one task

- Change sbatch parameters in `runscript.sh` to your preferences. Defaults are

```sh
#SBATCH --time=480:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=16G
```

- Change snakemake flags in `runscript.sh` to your preferences. Defaults are

```sh
snakemake --restart-times 3 --cores all --use-conda --keep-going --rerun-incomplete
```

- Schedule

```sh
sbatch ./runscript.sh
```

## To run with Slurm

- Get access to cookiecutter

```sh
conda install -c conda-forge cookiecutter
```

- Create config:

```sh
mkdir -p ~/.config/snakemake
cd ~/.config/snakemake
cookiecutter https://github.com/Snakemake-Profiles/slurm.git
```

- Modify `~/.config/snakemake/[profile name]/config.yaml` to your preferences.
For instance

```yaml
restart-times: 3
jobscript: "slurm-jobscript.sh"
cluster: "slurm-submit.py"
cluster-status: "slurm-status.py"
max-jobs-per-second: 1
max-status-checks-per-second: 10
local-cores: 1
latency-wait: 60
use-conda: True
keep-going: True
jobs: 10
rerun-incomplete: True
printshellcmds: True
```

- Create `~/.config/snakemake/[profile name]/cluster_config.yml` and fill with
default resources. For example

```yaml
__default__:
        account: def-rec3141  # your account
        partition: skylake    # the partition you use
        time: 480             # time in minutes
        nodes: 1              # number of nodes in use
        ntasks: 1             # number of simultaneous tasks
        mem: 16G              # default memory
        cpus-per-task: 24     # number of cores each task can use
```

- Run

```sh
snakemake --profile [profile name]
```
