
close all
clear
clc
overwrite = 0;
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
config_fns = dir('*AnalysisResults_batch.mat');

if isempty(config_fns)   %Throw and Error if no batch config files
    warning('\nNo batch configurations in selected directory %s\n',target_dir);
end

config_fns = fullfile(pwd, {config_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir
group0_SA = [];
group0_sn = [];
group1_SA = [];
group1_sn = [];

for cur_fn = 1:length(config_fns)
    temp = load(config_fns{cur_fn}); 
    group = whichGroup(temp.MouseNum);
     if group == true
       group1_SA = horzcat(group1_SA,length(temp.CompartmentTimes{1,1}) / (30)); % 30 fps, 60 sec per min %NOTE KENNEDY: IF DSFACTOR IS >1 THEN IT IS NOT 30FPS. If dsfactor is 2 then it is 15fps
       group1_sn = horzcat(group1_sn,length(temp.CompartmentTimes{1,2}) / (30));
     else
       group0_SA = horzcat(group0_SA, length(temp.CompartmentTimes{1,1}) / (30)); % 30 fps, 60 sec per min
       group0_sn = horzcat(group0_sn, length(temp.CompartmentTimes{1,2}) / (30));
     end  
    figure; hold on; 
    MouseLoc_smooth = SmoothMouseLocation(temp.MouseLoc,75); %second input is the 'maximum' jump for each frame. 
    plot(temp.MouseLoc(:,1), temp.MouseLoc(:,2),'color','r') 
    title('before smoothing');
    figure; hold on;
    plot(MouseLoc_smooth(:,1), MouseLoc_smooth(:,2),'color','k'); 
    title('after smoothing');
    
end

mean(group0_SA)
mean(group0_sn)
mean(group1_SA)
mean(group1_sn)
X = categorical({'Group 0', 'Group 1'});
data = [mean(group0_SA), mean(group0_sn); mean(group1_SA), mean(group1_sn)];
bar(X, data)
ylabel('Seconds')
