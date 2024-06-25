# Session 2.6 Software Containers for Scientific and High-Performance Computing

**Date:** Tuesday, June 25, 2024

**Summary**: Singularity is an open-source container engine designed to bring operating system-level virtualization to scientific and high-performance computing. With Singularity you can package complex computational workflows --- software applications, libraries, and data --- in a simple, portable, and reproducible way, which can then be run almost anywhere. 

**Presented by:** [Marty Kandes](https://www.linkedin.com/in/marty-kandes-b53a34144/) (mkandes  @sdsc.edu ) 

### Reading and Presentations:
* **Lecture material:**
    - https://jupyter-docker-stacks.readthedocs.io/en/latest/
* **Source Code/Examples:**

Download a container from a Docker registry.

  ```
  export SINGULARITY_CACHEDIR="/scratch/$USER/job_$SLURM_JOB_ID"
  ```
  ```
  singularity build scipy-notebook.sif docker://quay.io/jupyter/scipy-notebook:2024-05-27
  ```
    
### TASKS: None at this time.

[Back to Top](#top)
