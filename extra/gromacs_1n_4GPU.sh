#!/usr/bin/env bash
#SBATCH --job-name=gromacs-2020.4-expanse-gpu
#SBATCH --account=XYZ123
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=5
#SBATCH --mem=377393M
#SBATCH --gpus=4
#SBATCH --time=01:00:00
#SBATCH --output=gromacs-2020.4-expanse-gpu.%j.out

module purge
module load slurm
module load gpu/0.15.4
module load openmpi
module load gromacs

mpirun --mca btl_openib_allow_ib true -np 1  gmx_mpi grompp \
  -f pme.mdp \
  -c conf.gro \
  -p topol.top \
  -po "mdout.${SLURM_JOB_ID}.mdp" \
  -o "topol.${SLURM_JOB_ID}.tpr"

export OMP_NUM_THREADS=5
mpirun --mca btl_openib_allow_ib true -np 8  gmx_mpi mdrun \
  -nb gpu \
  -pme cpu \
  -bonded cpu \
  -pin on \
  -resethway \
  -noconfout \
  -nsteps 16000 \
  -s "topol.${SLURM_JOB_ID}.tpr" \
  -cpo "state.${SLURM_JOB_ID}.cpt" \
  -e "ener.${SLURM_JOB_ID}.edr" \
  -g "md.${SLURM_JOB_ID}.log" \
  -v