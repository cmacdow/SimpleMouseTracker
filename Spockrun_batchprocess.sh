#!/usr/bin/env bash
#SBATCH -J 'msTrack'
#SBATCH -o out/dynamicscript_output_%j.out 
#SBATCH -p all
#SBATCH -t 360
#SBATCH --exclude=redshirt-n[12-49]
#SBATCH --mem-per-cpu=12G
#SBATCH --mail-type=END
#SBATCH --mail-user=<temp@princeton.edu>
module load matlab/R2018a
cd "/jukebox/buschman/Projects/Cortical Dynamics/Mouse Models of Autism/Analysis Code/SimpleMouseTracker/PathsToProcess/"
xvfb-run -d matlab -nosplash -nodisplay -nodesktop -r "try;BatchProcess('/jukebox/buschman//Rodent Data/ASD Models/juvenille bedding preference/10-03-20/stranger cage was 301-305/312-cohort1-JBP.mp4JBP_1_batchConfig.mat');catch me;disp(me.message);end;exit;"