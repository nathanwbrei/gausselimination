#!/bin/bash 
#@ wall_clock_limit = 00:30:00
#@ job_name = pos-gauss-mpi-intel
#@ job_type = MPICH
#@ output = out_1_node_8_tasks__$(jobid).out
#@ error = error_1_node_8_tasks_$(jobid).out
#@ class = test
#@ node = 1
#@ total_tasks = 8
#@ node_usage = not_shared
#@ energy_policy_tag = gauss_2
#@ minimize_time_to_solution = yes
#@ notification = never
#@ island_count = 1
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh
. $HOME/.bashrc

module unload mpi.ibm
module load mpi.intel

#for i in `seq 1 4`;
#do
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
#done

#@ output = out_1_node_16_tasks__$(jobid).out
#@ error = error_1_node_16_tasks_$(jobid).out
#@ node = 1
#@ total_tasks = 16
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh
. $HOME/.bashrc

module unload mpi.ibm
module load mpi.intel

#for i in `seq 1 4`;
#do
   mpiexec -n 16 ./gauss ge_data/size64x64
   date
   mpiexec -n 16 ./gauss ge_data/size512x512
   date
   mpiexec -n 16 ./gauss ge_data/size1024x1024
   date
   mpiexec -n 16 ./gauss ge_data/size2048x2048
   date
   mpiexec -n 16 ./gauss ge_data/size4096x4096
   date
   mpiexec -n 16 ./gauss ge_data/size8192x8192
   date
#done

#@ output = out_2_node_32_tasks__$(jobid).out
#@ error = error_2_node_32_tasks_$(jobid).out
#@ node = 2
#@ total_tasks = 32
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh
. $HOME/.bashrc

module unload mpi.ibm
module load mpi.intel

#for i in `seq 1 4`;
#do
   mpiexec -n 32 ./gauss ge_data/size64x64
   date
   mpiexec -n 32 ./gauss ge_data/size512x512
   date
   mpiexec -n 32 ./gauss ge_data/size1024x1024
   date
   mpiexec -n 32 ./gauss ge_data/size2048x2048
   date
   mpiexec -n 32 ./gauss ge_data/size4096x4096
   date
   mpiexec -n 32 ./gauss ge_data/size8192x8192
   date
#done

#@ output = out_4_node_64_tasks__$(jobid).out
#@ error = error_8_node_64_tasks_$(jobid).out
#@ node = 4
#@ total_tasks = 64
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh
. $HOME/.bashrc

module unload mpi.ibm
module load mpi.intel

#for i in `seq 1 4`;
#do
   mpiexec -n 64 ./gauss ge_data/size64x64
   date
   mpiexec -n 64 ./gauss ge_data/size512x512
   date
   mpiexec -n 64 ./gauss ge_data/size1024x1024
   date
   mpiexec -n 64 ./gauss ge_data/size2048x2048
   date
   mpiexec -n 64 ./gauss ge_data/size4096x4096
   date
   mpiexec -n 64 ./gauss ge_data/size8192x8192
   date
#done


