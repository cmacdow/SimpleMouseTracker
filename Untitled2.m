%% SA
% compartment 1 = SA
% compartment 2 = empty
%time_spent_SA = length(CompartmentTimes{1,1}) / (30*60) % 30 fps, 60 sec per min
%time_spent_empty = length(CompartmentTimes{1,2}) / (30*60)

%%
close all
clear
clc
overwrite = 0;
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
config_fns = dir('*SN_AnalysisResults_batch.mat');


if isempty(config_fns)   %Throw and Error if no batch config files
    warning('\nNo batch configurations in selected directory %s\n',target_dir);
end

config_fns = fullfile(pwd, {config_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

group0_SA = [];
group0_empty = [];

group1_SA = [];
group1_empty = [];

for cur_fn = 1:length(config_fns)
    temp = load(config_fns{cur_fn}); 
    group = whichGroup(temp.MouseNum);
     if group == true
       group1_SA = horzcat(group1_SA,length(temp.CompartmentTimes{1,1}) / (30*60)); % 30 fps, 60 sec per min
       group1_empty = horzcat(group1_empty,length(temp.CompartmentTimes{1,2}) / (30*60));
    else
       group0_SA = horzcat(group0_SA, length(temp.CompartmentTimes{1,1}) / (30*60)); % 30 fps, 60 sec per min
       group0_empty = horzcat(group0_empty, length(temp.CompartmentTimes{1,2}) / (30*60));
     end  
    figure
    plot(temp.MouseLoc(:,1), temp.MouseLoc(:,2)) 
end

fprintf('\nCompleted Batch Processing of %d files \nElapsed Time: %d\n',length(config_fns),toc/60)

group0_SA
group0_empty

group1_SA
group1_empty

