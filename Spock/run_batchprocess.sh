#!/usr/bin/env bash
#SBATCH -J 'msTrack'
#SBATCH -o out/dynamicscript_output_%j.out 
#SBATCH -p all
#SBATCH -t 239
#SBATCH --exclude=redshirt-n[12-49]
#SBATCH --mem-per-cpu=10G
#SBATCH --mail-type=END
#SBATCH --mail-user=<temp@princeton.edu>
module load matlab/R2019b
module load gstreamer/1.14.0
cd "/jukebox/buschman/Projects/Cortical Dynamics/Mouse Models of Autism/Analysis Code/SimpleMouseTracker/"
xvfb-run -d matlab -nosplash -nodisplay -nodesktop -r "try;BatchProcess('/jukebox/buschman/Projects/Cortical Dynamics/Mouse Models of Autism/Analysis Code/testAVis/send to spock/301-cohort1-JBP.mp4_batchConfig.mat');catch me;disp(me.message);end;exit;"