# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Define common allocation and job-related environment variables
declare -xr CIML24_ACCOUNT='gue998'
declare -xr CIML24_RES_CPU='ciml24'
declare -xr CIML24_RES_GPU='ciml24gpu'
declare -xr CIML24_QOS_CPU='normal-eot'
declare -xr CIML24_QOS_GPU='gpu-shared-eot'

# Define pre-staged container and data directories
declare -xr CIML24_CONTAINER_DIR='/cm/shared/apps/containers/singularity'
declare -xr CIML24_DATA_DIR='/cm/shared/examples/sdsc/ciml/2024'

# Define srun-based interactive job command aliases
alias srun-shared="srun --account=${CIML24_ACCOUNT} --reservation=${CIML24_RES_CPU} --partition=shared --nodes=1 --ntasks-per-node=1 --cpus-per-task=4 --mem=16G --time=04:00:00 --pty --wait=0 /bin/bash"
alias srun-compute="srun --account=${CIML24_ACCOUNT} --reservation=${CIML24_RES_CPU} --partition=compute --qos=${CIML24_QOS_CPU} --nodes=1 --ntasks-per-node=1 --cpus-per-task=128 --mem=243G --time=04:00:00 --pty --wait=0 /bin/bash"
alias srun-gpu-shared="srun --account=${CIML24_ACCOUNT} --reservation=${CIML24_RES_GPU} --partition=gpu-shared --qos=${CIML24_QOS_GPU} --nodes=1 --ntasks-per-node=1 --cpus-per-task=10 --mem=92G --gpus=1 --time=04:00:00 --pty --wait=0 /bin/bash"

# Prepend the GALYLEO_INSTALL_DIR to each user's PATH
export PATH="/cm/shared/apps/sdsc/galyleo:${PATH}"

# Define galyleo-based Jupyter notebook session command aliases
alias jupyter-shared-spark="galyleo launch --account ${CIML24_ACCOUNT} --reservation ${CIML24_RES_CPU} --partition shared --cpus 4 --memory 16 --time-limit 04:00:00 --env-modules singularitypro --sif ${CIML24_CONTAINER_DIR}/spark/spark-latest.sif --bind /cm,/expanse,/scratch --quiet"
alias jupyter-compute-tensorflow="galyleo launch --account ${CIML24_ACCOUNT} --reservation ${CIML24_RES_CPU} --partition compute --qos ${CIML24_QOS_CPU} --cpus 128 --memory 243 --time-limit 04:00:00 --env-modules singularitypro --sif ${CIML24_CONTAINER_DIR}/tensorflow/tensorflow-latest.sif --bind /cm,/expanse,/scratch --quiet"
alias jupyter-gpu-shared-tensorflow="galyleo launch --account ${CIML24_ACCOUNT} --reservation ${CIML24_RES_GPU} --partition gpu-shared --qos ${CIML24_QOS_GPU} --cpus 10 --memory 92 --gpus 1 --time-limit 04:00:00 --env-modules singularitypro --sif ${CIML24_CONTAINER_DIR}/tensorflow/tensorflow-latest.sif --bind /cm,/expanse,/scratch --nv --quiet"
alias jupyter-compute-keras-nlp="galyleo launch --account ${CIML24_ACCOUNT} --reservation ${CIML24_RES_CPU} --partition compute --qos ${CIML24_QOS_CPU} --cpus 128 --memory 243 --time-limit 01:30:00 --conda-env keras-nlp --conda-yml keras-nlp.yaml --mamba --quiet"
alias jupyter-gpu-shared-llm="galyleo launch --account ${CIML24_ACCOUNT} --reservation ${CIML24_RES_GPU} --partition gpu-shared --qos ${CIML24_QOS_GPU} --cpus 4 --memory 32 --gpus 1 --time-limit 01:00:00 --env-modules singularitypro --sif /cm/shared/examples/sdsc/ciml//2024/LLM/ollama_late.sif --nv --bind /expanse,/scratch,/cm --quiet"