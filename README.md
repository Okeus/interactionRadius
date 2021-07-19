# interactionRadius
This is code for simulating the interaction radius from randomly dispersed microdroplets in a liquid medium.  It predicts the interaction radius, this represents 90% volume for the probability density function of increased temperature surrounding a single particle. 

The scripts are to be run on an HPC cluster computer. There are steps taken to implement the script on the cluster.

gaussianOverlap3D_v9c_batch.sh : Bash script for submitting single job from the job array. Allows the the number of cpus and amount of memory for each job to be pre-allocated.  Otherwise, the job will  probably fail due to memory errors.

gaussianOverlap3D_v9c_batch.m : Main matlab script.  This simulates the interaction radii matrices. Adjust matrix size with increasing or decreasing 'sfact' variable.  sfact=1 is 256x256x256 matrix.  sfact=4 is 1024x102x1024 matrix, etc. Randomly places spheres in the matrix with a convolution kernel, then summates the matrices.  

Load Matlab module
1. module load matlab

Compile Matlab code to execute script without the need for selecting licenses.
2. DISPLAY="" mcc -m -v -R '-nodisplay' -o gaussianOverlap3D_v9c_batch gaussianOverlap3D_v9c_batch.m

Submit the batch script to the cluster queue.
sbatch --array=1-80 gaussianOverlap3D_v9c_batch.sh

Move output files.
After all jobs are complete, make folders 'sums' and 'slices'.  Put .mat files in the 'sums' folder. Put .jpg files in the 'slices' folder.

Plot the output.
Execute 'gaussianOverlap3D_v9c_batch_plot_fill.m' to plot the simulation results versus the experimental data results.
