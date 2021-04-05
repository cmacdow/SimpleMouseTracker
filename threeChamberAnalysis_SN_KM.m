
close all
clear
clc
overwrite = 0;

% select folder with analysis files
target_dir = uigetdir; 
startdir = (pwd);
cd(target_dir);
config_fns = dir('*AnalysisResults_batch.mat');
config_fns = fullfile(pwd, {config_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

% select folder with raw batch files
target_dir = uigetdir; 
startdir = (pwd);
cd(target_dir);
config_fns_raw = dir('*batchConfig.mat');
config_fns_raw = fullfile(pwd, {config_fns_raw.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir


% allocate arrays for dimensions of compartments
SA_x = [];
SA_y = [];
SN_x = [];
SN_y = [];

% allocate arrays for number of seconds spent in each compartment 
group0_SA = [];
group0_sn = [];
group1_SA = [];
group1_sn = [];

genotype = [];
for cur_fn = 1:length(config_fns)
    
    config = load(config_fns_raw{cur_fn});
    analysis = load(config_fns{cur_fn}); 
    genotype = horzcat(genotype, whichGroup(analysis.MouseNum));
    group = whichGroup(analysis.MouseNum);
      
     if group == true
           group1_SA = horzcat(group1_SA,length(analysis.CompartmentTimes{1,1}) / (15)); 
           group1_sn = horzcat(group1_sn,length(analysis.CompartmentTimes{1,2}) / (15));
         else
           group0_SA = horzcat(group0_SA, length(analysis.CompartmentTimes{1,1}) / (15)); 
           group0_sn = horzcat(group0_sn, length(analysis.CompartmentTimes{1,2}) / (15));
    end 

%     % register dimensions of SA comartment
%     SA_compartment_B = min(config.CompartmentsPositions{1,1}(:,1));
%     SA_compartment_T = max(config.CompartmentsPositions{1,1}(:,1));
%     SA_compartment_L = min(config.CompartmentsPositions{1,1}(:,2));
%     SA_compartment_R = max(config.CompartmentsPositions{1,1}(:,2)); 
%     % regsiter dimensions of SN compartment
%     SN_compartment_B = min(config.CompartmentsPositions{1,2}(:,1));
%     SN_compartment_T = max(config.CompartmentsPositions{1,2}(:,1));
%     SN_compartment_L = min(config.CompartmentsPositions{1,2}(:,2));
%     SN_compartment_R = max(config.CompartmentsPositions{1,2}(:,2));      
%     % compute average size of compartment 
%     SA_x = horzcat(SA_x, (SA_compartment_R - SA_compartment_L));
%     SA_y = horzcat(SA_y, (SA_compartment_T - SA_compartment_B));
%     SN_x = horzcat(SN_x, (SN_compartment_R - SN_compartment_L));
%     SN_y = horzcat(SN_y, (SN_compartment_T - SN_compartment_B));    % preallocate arrays for mouse's location in middle chamber
%     mid_chamber_x = [];
%     mid_chamber_y = [];

   
        
        
        
    
         
    if sum(analysis.MouseNum == [309, 314, 316]) >= 1
       MouseLoc_smooth = SmoothMouseLocation(analysis.MouseLoc,20);
       analysis.MouseLoc(:,1) = MouseLoc_smooth(:,1);
       analysis.MouseLoc(:,2) = MouseLoc_smooth(:,2);   
    end
% 
%      % isolate mouse's location in center section of chamber
%         for i = 1:length(analysis.MouseLoc) 
%          temp = [0,0];
%              if SA_compartment_R < SN_compartment_L % if SA is on the left
%                  if (analysis.MouseLoc(i,1) > SA_compartment_R) && (analysis.MouseLoc(i,1) < SN_compartment_L)
%                      temp(1) = analysis.MouseLoc(i,1);
%                      temp(2) = analysis.MouseLoc(i,2);
%                      mid_chamber_x = horzcat(mid_chamber_x, temp(1));
%                      mid_chamber_y = horzcat(mid_chamber_y, temp(2));
%                  end    
%              else % if SA is on the right
%                   if (analysis.MouseLoc(i,1) > SN_compartment_R) && (analysis.MouseLoc(i,1) < SA_compartment_L)
%                      temp(1) = analysis.MouseLoc(i,1);
%                      temp(2) = analysis.MouseLoc(i,2);
%                      mid_chamber_x = horzcat(mid_chamber_x, temp(1));
%                      mid_chamber_y = horzcat(mid_chamber_y, temp(2));
%                   end     
%              end                
%         end
%     
           figure; hold on;
           plot(analysis.MouseLoc(:,1), analysis.MouseLoc(:,2),'color','r');
           SA_outline = rectangle('Position', [SA_compartment_L, SA_compartment_B, (SA_compartment_R - SA_compartment_L), (SA_compartment_T - SA_compartment_B)]);
           text(SA_compartment_L+(SA_compartment_R - SA_compartment_L)/2,SA_compartment_T + 20 ,'SA','HorizontalAlignment','center');
           SN_outline = rectangle('Position', [SN_compartment_L, SN_compartment_B, (SN_compartment_R - SN_compartment_L), (SN_compartment_T - SN_compartment_B)]);
           text(SN_compartment_L+(SN_compartment_R - SN_compartment_L)/2,SN_compartment_T + 20 ,'SN','HorizontalAlignment','center');
           set(gca, 'YDir','reverse','yticklabel',num2str(''),'xticklabel',num2str(''));
           str = 'Social Novelty Example Group '
           group = whichGroup(analysis.MouseNum)
           title({str, group });
           legend('Mouse Location');

end


%%
group0_SA = group0_SA(group0_SA ~= 0);
group0_sn = group0_sn(group0_sn ~= 0);
group1_SA = group1_SA(group1_SA ~= 0);
group1_sn = group1_sn(group1_sn ~= 0);
data = [group0_SA, group0_sn, group1_SA, group1_sn];
%8 8 5 5 
g = {'f0','f0','f0','f0','f0','f0','f0','f0',...
    's0','s0','s0','s0','s0','s0','s0','s0',...
    'f1','f1','f1','f1','f1',...
    's1','s1','s1','s1','s1',};
[p, tbl, stats] = anova1(data,g);
Fstat = tbl{2,5};
multcomp = multcompare(stats);

addpath(genpath('Z:\Rodent Data\Wide Field Microscopy\VPA_Mesoscale_Analysis'));
fp = fig_params_vpa; 
rng('default');
group0_SA_pos = 1+rand(length(group0_SA),1)/2-0.25;
group0_empty_pos = 2+rand(length(group0_sn),1)/2-0.25;
group1_SA_pos = 3+rand(length(group1_SA),1)/2-0.25; 
group1_empty_pos = 4+rand(length(group1_sn),1)/2-0.25; 

figure('position',[680   558   240   271]); hold on;

b = bar([nanmean(group0_SA),nanmean(group0_sn) nanmean(group1_SA),nanmean(group1_sn)],'FaceColor','flat','FaceAlpha',0.5,'EdgeColor',[1 1 1]);    
b.CData(1,:) = [.5 0 .5];
b.CData(2,:) = [0 .5 0];
b.CData(3,:) = [.5 0 .5];
b.CData(4,:) = [0 .5 0];

plot(group0_SA_pos,group0_SA,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group0_empty_pos,group0_sn,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)  
plot(group1_SA_pos,group1_SA,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group1_empty_pos,group1_sn,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot) 

sem_group0_SA = std(group0_SA) / sqrt(length(group0_SA));
sem_group0_empty = std(group0_sn)/ sqrt(length(group0_sn));
sem_group1_SA = std(group1_SA) / sqrt(length(group1_SA));
sem_group1_empty = std(group1_sn)/ sqrt(length(group1_sn));

errorbar(1,nanmean(group0_SA),sem_group0_SA,'LineWidth',1.5,'Color','k');
errorbar(2,nanmean(group0_sn),sem_group0_empty,'LineWidth',1.5,'Color','k');
errorbar(3,nanmean(group1_SA),sem_group1_SA,'LineWidth',1.5,'Color','k');
errorbar(4,nanmean(group1_sn),sem_group1_empty,'LineWidth',1.5,'Color','k');


pf0s0 = multcomp(1,6);
temp_f0s0 = max(horzcat(1,group0_SA,group0_sn));
line([1,2],[temp_f0s0+temp_f0s0*0.1,temp_f0s0+temp_f0s0*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(1.5, temp_f0s0+temp_f0s0*0.125,sprintf(str,pf0s0),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

pf1s1 = multcomp(6,6);
temp_f1s1 = max(horzcat(1,group1_SA,group1_sn));
line([3,4],[temp_f1s1*.9,temp_f1s1*.9],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3.5, temp_f1s1*.925,sprintf(str,pf1s1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

pf0f1 = multcomp(2,6);
temp_f0f1 = max(horzcat(1,group0_SA,group1_sn));
line([1,3],[temp_f0f1+temp_f0f1*0.1,temp_f0f1+temp_f0f1*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(2, temp_f0f1+temp_f0f1 *0.125,sprintf(str,pf0f1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

ps0s1 = multcomp(5,6);
temp_s0s1 = max(horzcat(1,group0_SA,group1_sn));
line([2,4],[temp_s0s1+temp_s0s1*0.05,temp_s0s1+temp_s0s1*0.05],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3, temp_s0s1+temp_s0s1*0.075,sprintf(str,ps0s1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

fp.FormatAxes(gca);
set(gca,'Clipping','off','box','off');   
set(gca,'xtick',[1.5, 3.5],'xticklabel',{'Group 0','Group 1'},'xticklabelrotation',90,'FontSize',10,'xlim',[0.25 5])
ylabel('Time Spent (sec)','FontSize',12)



%%  Calculating time spent in each compartment
% len.comp1 = length(analysis.CompartmentTimes{:,1})
% len.comp2 =  length(analysis.CompartmentTimes{:,2})
% len.mid = length(mid_chamber_x)
% len.mouseloc = length(analysis.MouseLoc)
% len.total = len.comp1 + len.comp2 + len.mid

%  index = find(analysis.MouseLoc(:,1) == SA_compartment_R) % indices of when MouseLoc falls on R edge of SA compart
%  sum = 0;
%  for 1:length(index)
%      if 
%      
% match = sum(index == analysis.CompartmentTimes{1,1} % see if indices match SA compartment times
%  