# bbpipe Snakemake
Make sure that you put the data you want to use in `./data/` before running.
## To run:
- Run `snakemake --cores [number of threads to use] --use-conda`.
## To use with Slurm job scheduler: 
- Get access to cookiecutter:
  -  `conda install -c conda-forge cookiecutter`
- Create config:
  - `mkdir -p ~/.config/snakemake`
  - `cd ~/.config/snakemake`
  - `cookiecutter https://github.com/Snakemake-Profiles/slurm.git`
- Modify `~/.config/snakemake/[profile name]/config.yaml` to your preferences. 
For instance:
```
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
- Create `~/.config/snakemake/[profile name]/cluster_config.yml` and fill with default resources.
For example:
```
__default__:
        account: def-rec3141  # your account
        partition: skylake    # the partition you use
        time: 480             # time in minutes
        nodes: 1              # number of nodes in use
        ntasks: 1             # number of simultaneous tasks
        mem: 16G              # default memory
        cpus-per-task: 24     # number of cores each task can use
```
