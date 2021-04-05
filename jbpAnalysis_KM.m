
close all
clear
clc
overwrite = 0;
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
config_fns = dir('*_AnalysisResults_batch.mat');
config_fns = fullfile(pwd, {config_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
config_fns_raw = dir('*batchConfig.mat');
config_fns_raw = fullfile(pwd, {config_fns_raw.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

mice = [301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 331, 332, 333,...
    334, 335, 336, 337, 338, 339 340, 341, 342, 343, 344];

data_each_trial = cell(length(mice), 1);
data_each_trial(:) = {NaN(3,4)};
for cur_fn = 1:length(config_fns)
    config = load(config_fns_raw{cur_fn});
    analysis = load(config_fns{cur_fn}); 
    mouse_num = analysis.MouseNum;
    trial = str2num(analysis.ExpType);
    familiar = length(analysis.CompartmentTimes{1,1}) / (15); 
    stranger = length(analysis.CompartmentTimes{1,2}) / (15);
    index = find(mice == analysis.MouseNum);
   data_each_trial{index}(1,trial) = familiar;
   data_each_trial{index}(2,trial) = stranger;
   data_each_trial{index}(1,4) =  mouse_num;
   
   
   % register dimensions of familiar compartment
    comp1_B = min(config.CompartmentsPositions{1,1}(:,1));
    comp1_T = max(config.CompartmentsPositions{1,1}(:,1));
    comp1_L = min(config.CompartmentsPositions{1,1}(:,2));
    comp1_R = max(config.CompartmentsPositions{1,1}(:,2)); 
    % regsiter dimensions of stranger compartment
    comp2_B = min(config.CompartmentsPositions{1,2}(:,1));
    comp2_T = max(config.CompartmentsPositions{1,2}(:,1));
    comp2_L = min(config.CompartmentsPositions{1,2}(:,2));
    comp2_R = max(config.CompartmentsPositions{1,2}(:,2));
    % register dimensions of center (open field)
    if comp2_R > comp1_R
        mid_R = comp2_L;
        mid_L = comp1_R;
    else 
        mid_R = comp1_L;
        mid_L = comp2_R;
    end
    mid_B = (comp2_B + comp1_B)/2;
    mid_T = (comp2_T + comp1_T)/2;
   
    mid_chamber_x = [];
    mid_chamber_y = [];
    % isolate mouse's location in center section of chamber
    for i = 1:length(analysis.MouseLoc) 
        temp = [0,0];
           if (analysis.MouseLoc(i,1) > mid_L) && (analysis.MouseLoc(i,1) < mid_R)
               temp(1) = analysis.MouseLoc(i,1);
               temp(2) = analysis.MouseLoc(i,2);
               mid_chamber_x = horzcat(mid_chamber_x, temp(1));
               mid_chamber_y = horzcat(mid_chamber_y, temp(2));
           end
    end 
    time_spent_mid = length(mid_chamber_x)/15;
    data_each_trial{index}(3,trial) = time_spent_mid;
end

average_over_trials = cell(length(mice), 1);
average_over_trials(:) = {NaN(3,2)};
group0_familiar = [];
group0_stranger = [];
group0_mid = [];
group1_familiar = [];
group1_stranger = [];
group1_mid = [];

mouse_num = [];
for i = 1:length(mice)
    average_over_trials{i}(1,1) = nanmean(data_each_trial{i}(1,1:3));
    average_over_trials{i}(2,1) = nanmean(data_each_trial{i}(2,1:3));
    average_over_trials{i}(3,1) = nanmean(data_each_trial{i}(3,1:3));
    mouse_num = horzcat(mouse_num, data_each_trial{i}(1,4));
    if isnan(data_each_trial{i}(1,4))
       average_over_trials{i}(1,2) = 2;
    else
        average_over_trials{i}(1,2) = whichGroup(data_each_trial{i}(1,4));
    end

    if average_over_trials{i}(1,2) == true
       group1_familiar = horzcat(group1_familiar, average_over_trials{i}(1,1)); 
       group1_stranger = horzcat(group1_stranger, average_over_trials{i}(2,1));
       group1_mid = horzcat(group1_mid, average_over_trials{i}(3,1));
    else 
       group0_familiar = horzcat(group0_familiar, average_over_trials{i}(1,1)); 
       group0_stranger = horzcat(group0_stranger, average_over_trials{i}(2,1));
       group0_mid = horzcat(group0_mid, average_over_trials{i}(3,1));
    end  
end

group0_familiar = group0_familiar(~isnan(group0_familiar));
group0_stranger = group0_stranger(~isnan(group0_stranger));
group0_mid = group0_mid(~isnan(group0_mid));

%% time spent on either bedding separated by group
% 15 15 13 13
data = [group0_familiar, group0_stranger, group1_familiar, group1_stranger];
g = {'f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0',...
    's0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0',...
    'f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1',...
    's1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1'};
[p, tbl, stats] = anova1(data,g);
Fstat = tbl{2,5};
multcomp = multcompare(stats); %Tukey posthoc

savedir = 'Z:\Users\Kennedy\thesis\figures';
addpath(genpath('Z:\Rodent Data\Wide Field Microscopy\VPA_Mesoscale_Analysis'));
fp = fig_params_vpa; 
% group = genotype;
rng('default');
group0_SA_pos = 1+rand(length(group0_familiar),1)/2-0.25;
group0_empty_pos = 2+rand(length(group0_stranger),1)/2-0.25;
group1_SA_pos = 3+rand(length(group1_familiar),1)/2-0.25; 
group1_empty_pos = 4+rand(length(group1_stranger),1)/2-0.25; 

figure('position',[680   558   240   271]); hold on;

b = bar([nanmean(group0_familiar),nanmean(group0_stranger) nanmean(group1_familiar),nanmean(group1_stranger)],'FaceColor','flat','FaceAlpha',0.5,'EdgeColor',[1 1 1]);    
b.CData(1,:) = [.5 0 .5];
b.CData(2,:) = [0 .5 0];
b.CData(3,:) = [.5 0 .5];
b.CData(4,:) = [0 .5 0];
%legend([axes], 'label');
%legend(b,'title');
plot(group0_SA_pos,group0_familiar,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group0_empty_pos,group0_stranger,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)  
plot(group1_SA_pos,group1_familiar,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group1_empty_pos,group1_stranger,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot) 

sem_group0_SA = std(group0_familiar) / sqrt(length(group0_familiar));
sem_group0_empty = std(group0_stranger)/ sqrt(length(group0_stranger));
sem_group1_SA = std(group1_familiar) / sqrt(length(group1_familiar));
sem_group1_empty = std(group1_stranger)/ sqrt(length(group1_stranger));

errorbar(1,nanmean(group0_familiar),sem_group0_SA,'LineWidth',1.5,'Color','k');
errorbar(2,nanmean(group0_stranger),sem_group0_empty,'LineWidth',1.5,'Color','k');
errorbar(3,nanmean(group1_familiar),sem_group1_SA,'LineWidth',1.5,'Color','k');
errorbar(4,nanmean(group1_stranger),sem_group1_empty,'LineWidth',1.5,'Color','k');

pf0s0 = multcomp(1,6);
temp_f0s0 = max(horzcat(1,group0_familiar,group0_stranger));
line([1,2],[temp_f0s0+temp_f0s0*0.1,temp_f0s0+temp_f0s0*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(1.5, temp_f0s0+temp_f0s0*0.125,sprintf(str,pf0s0),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

pf1s1 = multcomp(6,6);
temp_f1s1 = max(horzcat(1,group1_familiar,group1_stranger));
line([3,4],[temp_f1s1+temp_f1s1*0.1,temp_f1s1+temp_f1s1*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3.5, temp_f1s1+temp_f1s1*0.125,sprintf(str,pf1s1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

pf0f1 = multcomp(2,6);
temp_f0f1 = max(horzcat(1,group0_familiar,group1_familiar));
line([1,3],[temp_f0f1+temp_f0f1*0.1,temp_f0f1+temp_f0f1*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(2, temp_f0f1+temp_f0f1 *0.125,sprintf(str,pf0f1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

ps0s1 = multcomp(5,6);
temp_s0s1 = max(horzcat(1,group0_stranger,group1_stranger));
line([2,4],[temp_s0s1+temp_s0s1*0.05,temp_s0s1+temp_s0s1*0.05],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3, temp_s0s1+temp_s0s1*0.075,sprintf(str,ps0s1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

fp.FormatAxes(gca);
set(gca,'Clipping','off','box','off');   
set(gca,'xtick',[1.5, 3.5],'xticklabel',{'Group 0','Group 1'},'xticklabelrotation',90,'FontSize',10,'xlim',[0.25 5])
ylabel('Time Spent (sec)','FontSize',12)
%% plot time spent in the middle of the chamber
mouse_num = mouse_num(~isnan(mouse_num));
addpath(genpath('Z:\Rodent Data\Wide Field Microscopy\VPA_Mesoscale_Analysis'));
    fp = fig_params_vpa; 
    group = whichGroup(mouse_num);
    rng('default');
    group_0_pos = 1+rand(sum(group==0),1)/2-0.25;
    group_1_pos = 2+rand(sum(group==1),1)/2-0.25; %generate random positions for jitter plot
    figure('position',[680   558   240   271]); hold on;
    group0 = group0_mid;
    group1 = group1_mid;
    b = bar([nanmean(group0),nanmean(group1)],'FaceColor','flat','FaceAlpha',0.5,'EdgeColor',[1 1 1]);    
    b.CData(1,:) = [fp.c_sal_gray];
    b.CData(2,:) = [fp.c_vpa_gray];
    plot(group_0_pos,group0,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
    plot(group_1_pos,group1,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)    

    sem_group0 = std(group0) / sqrt(length(group0));
    sem_group1 = std(group1) / sqrt(length(group1));

    errorbar(1,nanmean(group0),sem_group0,'LineWidth',1.5,'Color','k');
    errorbar(2,nanmean(group1),sem_group1,'LineWidth',1.5,'Color','k');
    [p,~] = ranksum(group0,group1);
    temp = max(horzcat(1,group0,group1));
    line([1,2],[temp+temp*0.05,temp+temp*0.05],'linewidth',1.5,'color','k');
    str = 'p = %0.2g';
    text(1.5, temp+temp*0.15,sprintf(str,p),'Rotation',0,'FontSize',10,'HorizontalAlignment','center');
    fp.FormatAxes(gca);
    set(gca,'Clipping','off','box','off');   
    set(gca,'xtick',[1,2],'xticklabel',{'Group 0','Group 1'},'xticklabelrotation',90,'FontSize', 14,'xlim',[0.25 2.75])
    ylabel('Time spent middle (sec)', 'FontSize',14);
    set(gca,'LineWidth',4);



%% fining middle dimensions and plotting open field
for cur_fn = 1:length(config_fns)
    config = load(config_fns_raw{cur_fn});
    analysis = load(config_fns{cur_fn}); 
    mouse_num = analysis.MouseNum;
    trial = str2num(analysis.ExpType);
    % register dimensions of familiar compartment
    comp1_B = min(config.CompartmentsPositions{1,1}(:,1));
    comp1_T = max(config.CompartmentsPositions{1,1}(:,1));
    comp1_L = min(config.CompartmentsPositions{1,1}(:,2));
    comp1_R = max(config.CompartmentsPositions{1,1}(:,2)); 
    % regsiter dimensions of stranger compartment
    comp2_B = min(config.CompartmentsPositions{1,2}(:,1));
    comp2_T = max(config.CompartmentsPositions{1,2}(:,1));
    comp2_L = min(config.CompartmentsPositions{1,2}(:,2));
    comp2_R = max(config.CompartmentsPositions{1,2}(:,2));
    % register dimensions of center (open field)
    if comp2_R > comp1_R
        mid_R = comp2_L;
        mid_L = comp1_R;
    else 
        mid_R = comp1_L;
        mid_L = comp2_R;
    end
    mid_B = (comp2_B + comp1_B)/2;
    mid_T = (comp2_T + comp1_T)/2;
   
    mid_chamber_x = [];
    mid_chamber_y = [];
    % isolate mouse's location in center section of chamber
    for i = 1:length(analysis.MouseLoc) 
        temp = [0,0];
           if (analysis.MouseLoc(i,1) > mid_L) && (analysis.MouseLoc(i,1) < mid_R)
               temp(1) = analysis.MouseLoc(i,1);
               temp(2) = analysis.MouseLoc(i,2);
               mid_chamber_x = horzcat(mid_chamber_x, temp(1));
               mid_chamber_y = horzcat(mid_chamber_y, temp(2));
           end
    end 
    
%    figure; hold on;
%    plot(analysis.MouseLoc(:,1), analysis.MouseLoc(:,2),'color','r') 
%    comp1_outline = rectangle('Position', [comp1_L, comp1_B, (comp1_R - comp1_L), (comp1_T - comp1_B)]);
%    text(comp1_L+(comp1_R - comp1_L)/2, comp1_T + 20 ,'Familiar','HorizontalAlignment','center');
%    stranger_outline = rectangle('Position', [comp2_L, comp2_B, (comp2_R - comp2_L), (comp2_T - comp2_B)]);
%    text(comp2_L+(comp2_R - comp2_L)/2,comp2_T + 20 ,'Stranger','HorizontalAlignment','center');
%    mid_outline = rectangle('Position', [mid_L, mid_B, (mid_R - mid_L), (mid_T - mid_B)]);
%    text(mid_L +(mid_R - mid_L)/2, mid_T +20,'open field','HorizontalAlignment','center');
%    set(gca, 'YDir','reverse','yticklabel',num2str(''),'xticklabel',num2str(''));
%    str = 'JBP'
%    group = whichGroup(analysis.MouseNum)
%    title({str, group });
%    legend('Mouse Location');
end


%% plotting 
group0_familiar = [];
group0_stranger = [];
group1_familiar = [];
group1_stranger = [];

for cur_fn = 1: length(config_fns)
    config = load(config_fns_raw{cur_fn});
    analysis = load(config_fns{cur_fn}); 

    group = whichGroup(analysis.MouseNum);
     if group == true
       group1_familiar = horzcat(group1_familiar,length(analysis.CompartmentTimes{1,1}) / (15)); 
       group1_stranger = horzcat(group1_stranger,length(analysis.CompartmentTimes{1,2}) / (15));
     else
       group0_familiar = horzcat(group0_familiar, length(analysis.CompartmentTimes{1,1}) / (15)); 
       group0_stranger = horzcat(group0_stranger, length(analysis.CompartmentTimes{1,2}) / (15));
     end  
    figure
    plot(analysis.MouseLoc(:,1), analysis.MouseLoc(:,2)) 
    title({ analysis.MouseNum analysis.ExpType})
    axis([180 500 70 290])
    set(gca, 'YDir', 'reverse')
end

%% using data from every trial (without avergaing by animal)

data = [group0_familiar, group0_stranger, group1_familiar, group1_stranger];
g = {'f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0','f0', 's0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','s0','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','f1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1','s1'};
[p, tbl, stats] = anova1(data,g);
Fstat = tbl{2,5};

savedir = 'Z:\Users\Kennedy\thesis\figures';
addpath(genpath('Z:\Rodent Data\Wide Field Microscopy\VPA_Mesoscale_Analysis'));
fp = fig_params_vpa; 
% group = genotype;
rng('default');
group0_SA_pos = 1+rand(length(group0_familiar),1)/2-0.25;
group0_empty_pos = 2+rand(length(group0_stranger),1)/2-0.25;
group1_SA_pos = 3+rand(length(group1_familiar),1)/2-0.25; 
group1_empty_pos = 4+rand(length(group1_stranger),1)/2-0.25; 

figure('position',[680   558   240   271]); hold on;

b = bar([nanmean(group0_familiar),nanmean(group0_stranger) nanmean(group1_familiar),nanmean(group1_stranger)],'FaceColor','flat','FaceAlpha',0.5,'EdgeColor',[1 1 1]);    
b.CData(1,:) = [.5 0 .5];
b.CData(2,:) = [0 .5 0];
b.CData(3,:) = [.5 0 .5];
b.CData(4,:) = [0 .5 0];

plot(group0_SA_pos,group0_familiar,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group0_empty_pos,group0_stranger,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)  
plot(group1_SA_pos,group1_familiar,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group1_empty_pos,group1_stranger,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot) 

sem_group0_SA = std(group0_familiar) / sqrt(length(group0_familiar));
sem_group0_empty = std(group0_stranger)/ sqrt(length(group0_stranger));
sem_group1_SA = std(group1_familiar) / sqrt(length(group1_familiar));
sem_group1_empty = std(group1_stranger)/ sqrt(length(group1_stranger));

errorbar(1,nanmean(group0_familiar),sem_group0_SA,'LineWidth',1.5,'Color','k');
errorbar(2,nanmean(group0_stranger),sem_group0_empty,'LineWidth',1.5,'Color','k');
errorbar(3,nanmean(group1_familiar),sem_group1_SA,'LineWidth',1.5,'Color','k');
errorbar(4,nanmean(group1_stranger),sem_group1_empty,'LineWidth',1.5,'Color','k');

%[p,~] = ranksum(group0);
%temp = max(cat(1,group0,group1));
%line([1,2],[temp+temp*0.025,temp+temp*0.025],'linewidth',1.5,'color','k');
%str = 'p = %0.2g';
%text(1.5, temp+temp*0.15,sprintf(str,p),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');
fp.FormatAxes(gca);
set(gca,'Clipping','off','box','off');   
set(gca,'units','centimeters','position',[2 2 2.5 3])

set(gca,'xtick',[1.5, 3.5],'xticklabel',{'Group 0','Group 1'},'xticklabelrotation',90,'FontSize',10,'xlim',[0.25 5])
ylabel('Time Spent in Compartment (sec)','FontSize',7)

