#!/bin/bash 
#@ wall_clock_limit = 00:30:00
#@ job_name = pos-gauss-mpi-intel
#@ job_type = MPICH
#@ output = non_blocking_out_1_node_8_procs_$(jobid).out
#@ error = no_nblocking_error_1_node_8_procs$(jobid).out
#@ class = test
#@ node = 1
#@ total_tasks = 8
#@ node_usage = not_shared
#@ energy_policy_tag = gauss_9
#@ minimize_time_to_solution = yes
#@ notification = never
#@ island_count = 1
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh
. $HOME/.bashrc

module unload mpi.ibm
module load mpi.intel

mpiexec -n 8 ./gauss ge_data/size64x64
date
mpiexec -n 8 ./gauss ge_data/size512x512
date
mpiexec -n 8 ./gauss ge_data/size1024x1024
date
mpiexec -n 8 ./gauss ge_data/size2048x2048
date
mpiexec -n 8 ./gauss ge_data/size4096x4096
date
mpiexec -n 8 ./gauss ge_data/size8192x8192
date

