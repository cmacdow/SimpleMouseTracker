
close all
clear
clc
overwrite = 0;
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
config_fns = dir('*AnalysisResults_batch.mat');
config_fns = fullfile(pwd, {config_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir


target_dir = uigetdir; 
startdir = (pwd);
cd(target_dir);
config_fns_raw = dir('*batchConfig.mat');
config_fns_raw = fullfile(pwd, {config_fns_raw.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

%% check dsFactor and  plot for obvious mis-trackings of mosue

% check dsFactor to make sure consistent
dsFactor = [];
length_mouseloc = [];
for cur_fn = 1:length(config_fns)
    analysis = load(config_fns{cur_fn}); 
    config = load(config_fns_raw{cur_fn});
    dsFactor = vertcat(dsFactor, config.dsFactor);
    length_mouseloc = vertcat(length_mouseloc, length(analysis.MouseLoc));
    
    % raw trace of MouseLoc
    figure; hold on;
    subplot(2,1,1);
    plot(analysis.MouseLoc(:,1), analysis.MouseLoc(:,2),'color','k');
    set(gca, 'YDir','reverse');
    title({ analysis.MouseNum analysis.ExpType config.MouseNum config.ExpType});
    
    % MouseLoc smoothed    
    subplot(2,1,2)
    MouseLoc_smooth = SmoothMouseLocation(analysis.MouseLoc,20);
    plot(MouseLoc_smooth(:,1), MouseLoc_smooth(:,2),'color','r'); 
    set(gca, 'YDir','reverse')
    title('smoothed');
end

%% Quick check for correct tracking of mouse location 
% plot MouseLoc points one at a time and compare with video
% y axis must be reversed because matlab changes axes during processing

for cur_fn = 1:length(analysis.MouseLoc)
    figure()
    hold on;
    for i = 1:2000
        x = analysis.MouseLoc(i,1)
        y = analysis.MouseLoc(i,2)
        plot(x,y,'-o')
        set(gca, 'YDir','reverse')
        axis([100 600 60 380])
        pause(.05)
    end
end


%% Figure out jump length needed for smoothing function

% change SmoothMouseLocation funciton input, array name and name of plot
for cur_fn = 10:11
    analysis = load(config_fns{cur_fn}); 

    % raw trace of MouseLoc
    figure; hold on;
    subplot(2,2,1);
    plot(analysis.MouseLoc(:,1), analysis.MouseLoc(:,2),'color','k');
    set(gca, 'YDir','reverse');
    title({ analysis.MouseNum analysis.ExpType });
    
    % MouseLoc smoothed    
    subplot(2,2,2);
    MouseLoc_smooth_30 = SmoothMouseLocation(analysis.MouseLoc,30);
    plot(MouseLoc_smooth_30(:,1), MouseLoc_smooth_30(:,2),'color','r'); 
    set(gca, 'YDir','reverse')
    title('smoothed 30');
    
    subplot(2,2,3);
    MouseLoc_smooth_25 = SmoothMouseLocation(analysis.MouseLoc,25);
    plot(MouseLoc_smooth_25(:,1), MouseLoc_smooth_25(:,2),'color','r'); 
    set(gca, 'YDir','reverse')
    title('smoothed 25');
    
    subplot(2,2,4);
    MouseLoc_smooth_20= SmoothMouseLocation(analysis.MouseLoc,20);
    plot(MouseLoc_smooth_20(:,1), MouseLoc_smooth_20(:,2),'color','r'); 
    set(gca, 'YDir','reverse')
    title('smoothed 20');
    
  
end