#!/usr/bin/env bash

#SBATCH --job-name=gromacs-mpi-omp-cuda-h20
#SBATCH --account=use300
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=5
#SBATCH --mem=368G
#SBATCH --gpus=4
#SBATCH --time=01:00:00
#SBATCH --output=%x.o%j.%N

declare -xr SCHEDULER_MODULE='slurm/expanse/21.08.8'
declare -xr SOFTWARE_MODULE='gpu/0.15.4'
declare -xr COMPILER_MODULE='gcc/8.5.0'
declare -xr CMAKE_MODULE='cmake/3.18.2'
declare -xr MPI_MODULE='openmpi/4.0.5'
declare -xr CUDA_MODULE='cuda10.2/toolkit/10.2.89'

declare -xr GROMACS_VERSION='2021.5'
declare -xr GROMACS_BUILD='mpi-omp-cuda'
declare -xr GROMACS_ROOT_DIR="${PWD}"
declare -xr GROMACS_ROOT_URL='http://ftp.gromacs.org/pub'
declare -xr GROMACS_INSTALL_DIR="${GROMACS_ROOT_DIR}/${GROMACS_VERSION}/${GROMACS_BUILD}/${COMPILER_MODULE}/${MPI_MODULE}/${CUDA_MODULE}"

declare -xr GROMACS_BENCHMARK='water-cut1.0_GMX50_bare'
declare -xr GROMACS_BENCHMARK_SIZE='3072'
declare -xr GROMACS_BENCHMARK_DATA_DIR="${GROMACS_ROOT_DIR}/benchmarks/${GROMACS_BENCHMARK}/${GROMACS_BENCHMARK_SIZE}"

module purge
module load "${SCHEDULER_MODULE}"
module load "${SOFTWARE_MODULE}"
#module load "${COMPILER_MODULE}"
module load "${CMAKE_MODULE}"
module load "${MPI_MODULE}"
module load "${CUDA_MODULE}"
source "${GROMACS_INSTALL_DIR}/bin/GMXRC"
printenv

cd "${GROMACS_ROOT_DIR}"

if [[ ! -d "${GROMACS_ROOT_DIR}/benchmarks" ]]; then
  mkdir -p "${GROMACS_ROOT_DIR}/benchmarks"
fi

cd "${GROMACS_ROOT_DIR}/benchmarks"

if [[ ! -d "${GROMACS_BENCHMARK_DATA_DIR}" ]]; then
  if [[ ! -f "${GROMACS_ROOT_DIR}/benchmarks/${GROMACS_BENCHMARK_TARBALL}" ]]; then
    wget "${GROMACS_ROOT_URL}/benchmarks/${GROMACS_BENCHMARK_TARBALL}"
  fi
  tar -xf "${GROMACS_BENCHMARK_TARBALL}"
fi

cd "${SLURM_SUBMIT_DIR}"

time -p mpirun -n 1 gmx_mpi grompp \
  -f "${GROMACS_BENCHMARK_DATA_DIR}/pme.mdp" \
  -c "${GROMACS_BENCHMARK_DATA_DIR}/conf.gro" \
  -p "${GROMACS_BENCHMARK_DATA_DIR}/topol.top" \
  -po "mdout.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.mdp" \
  -o "topol.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.tpr"

export OMP_NUM_THREADS=5
time -p mpirun --mca btl_openib_allow_ib true -np 8  gmx_mpi mdrun \
  -nb gpu \
  -pme cpu \
  -bonded cpu \
  -pin on \
  -resethway \
  -noconfout \
  -nsteps 16000 \
  -s "topol.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.tpr" \
  -cpo "state.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.cpt" \
  -e "ener.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.edr" \
  -g "md.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.log" \
  -v

rm mdout.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.mdp
rm topol.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.tpr
rm state.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.cpt
rm ener.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.edr
rm md.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.log