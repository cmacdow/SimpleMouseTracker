
close all
clear
clc
overwrite = 0;

% Find folder with Analysis Results Files
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
config_fns = dir('*AnalysisResults_batch.mat');
config_fns = fullfile(pwd, {config_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

% Find folder with Batch Config files
target_dir = uigetdir; 
startdir = (pwd);
cd(target_dir);
config_fns_raw = dir('*batchConfig.mat');
config_fns_raw = fullfile(pwd, {config_fns_raw.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

% allocate arrays for dimensions of compartments
SA_x = [];
SA_y = [];
empty_x = [];
empty_y = [];


% allocate arrays for number of seconds spent in each compartment 
group0_SA = [];
group0_empty = [];
group1_SA = [];
group1_empty = [];

group0_entrencesSA = [];
group0_entrencesSN = [];
group1_entrencesSA = [];
group1_entrencesSN = [];
genotype = [];
for cur_fn = 1:length(config_fns)
    
    analysis = load(config_fns{cur_fn}); 
    config = load(config_fns_raw{cur_fn});
    
    genotype = horzcat(genotype, whichGroup(analysis.MouseNum));
    group = whichGroup(analysis.MouseNum);
    
    
    % register dimensions of SA compartment
    SA_compartment_B = min(config.CompartmentsPositions{1,1}(:,1));
    SA_compartment_T = max(config.CompartmentsPositions{1,1}(:,1));
    SA_compartment_L = min(config.CompartmentsPositions{1,1}(:,2));
    SA_compartment_R = max(config.CompartmentsPositions{1,1}(:,2)); 
    % regsiter dimensions of empty compartment
    empty_compartment_B = min(config.CompartmentsPositions{1,2}(:,1));
    empty_compartment_T = max(config.CompartmentsPositions{1,2}(:,1));
    empty_compartment_L = min(config.CompartmentsPositions{1,2}(:,2));
    empty_compartment_R = max(config.CompartmentsPositions{1,2}(:,2));      
    % compute average size of compartment 
    SA_x = horzcat(SA_x, (SA_compartment_R - SA_compartment_L));
    SA_y = horzcat(SA_y, (SA_compartment_T - SA_compartment_B));
    empty_x = horzcat(empty_x, (empty_compartment_R - empty_compartment_L));
    empty_y = horzcat(empty_y, (empty_compartment_T - empty_compartment_B));    % preallocate arrays for mouse's location in middle chamber
        
    % plotting mouse location
    if analysis.MouseNum == 303
         MouseLoc_smooth = SmoothMouseLocation(analysis.MouseLoc,20);
       analysis.MouseLoc(:,1) = MouseLoc_smooth(:,1);
       analysis.MouseLoc(:,2) = MouseLoc_smooth(:,2);   
    end
    
    mid_chamber_x = [];
    mid_chamber_y = [];
    % isolate mouse's location in center section of chamber
        for i = 1:length(analysis.MouseLoc) 
         temp = [0,0];
             if SA_compartment_R < empty_compartment_L % if SA is on the left
                 if (analysis.MouseLoc(i,1) > SA_compartment_R) && (analysis.MouseLoc(i,1) < empty_compartment_L)
                     temp(1) = analysis.MouseLoc(i,1);
                     temp(2) = analysis.MouseLoc(i,2);
                     mid_chamber_x = horzcat(mid_chamber_x, temp(1));
                     mid_chamber_y = horzcat(mid_chamber_y, temp(2));
                 end    
             else % if SA is on the right
                  if (analysis.MouseLoc(i,1) > empty_compartment_R) && (analysis.MouseLoc(i,1) < SA_compartment_L)
                     temp(1) = analysis.MouseLoc(i,1);
                     temp(2) = analysis.MouseLoc(i,2);
                     mid_chamber_x = horzcat(mid_chamber_x, temp(1));
                     mid_chamber_y = horzcat(mid_chamber_y, temp(2));
                  end     
             end  
        end
        % calculate number of times entered and exited
     entrence_SA = 1;
      for i = 1:(length(analysis.CompartmentTimes{1})-1)
          if ((analysis.CompartmentTimes{1}(i+1)) - analysis.CompartmentTimes{1}(i)) > 30
              entrence_SA = entrence_SA +1;
          end
      end      
      entrence_SN = 1;
      for i = 1:(length(analysis.CompartmentTimes{2})-1)
          if ((analysis.CompartmentTimes{2}(i+1)) - analysis.CompartmentTimes{2}(i)) > 30
              entrence_SN = entrence_SN +1;
          end
      end
        % calculating time spent in SA vs Empty compartment
    if group == true
           group1_SA = horzcat(group1_SA,length(analysis.CompartmentTimes{1,1}) / (15)); 
           group1_empty = horzcat(group1_empty,length(analysis.CompartmentTimes{1,2}) / (15));
           group1_entrencesSA = horzcat(group1_entrencesSA, entrence_SA);
           group1_entrencesSN = horzcat(group1_entrencesSN, entrence_SN);
    
    else
           group0_SA = horzcat(group0_SA, length(analysis.CompartmentTimes{1,1}) / (15)); 
           group0_empty = horzcat(group0_empty, length(analysis.CompartmentTimes{1,2}) / (15));
           group0_entrencesSA = horzcat(group0_entrencesSA, entrence_SA);
           group0_entrencesSN = horzcat(group0_entrencesSN, entrence_SN);
    end  
      
%    figure; hold on;
%    plot(analysis.MouseLoc(:,1), analysis.MouseLoc(:,2),'color','r') 
%    SA_outline = rectangle('Position', [SA_compartment_L, SA_compartment_B, (SA_compartment_R - SA_compartment_L), (SA_compartment_T - SA_compartment_B)]);
%    text(SA_compartment_L+(SA_compartment_R - SA_compartment_L)/2,SA_compartment_T + 20 ,'SA Compartment','HorizontalAlignment','center');
%    empty_outline = rectangle('Position', [empty_compartment_L, empty_compartment_B, (empty_compartment_R - empty_compartment_L), (empty_compartment_T - empty_compartment_B)]);
%    text(empty_compartment_L+(empty_compartment_R - empty_compartment_L)/2,empty_compartment_T + 20 ,'Empty Compartment','HorizontalAlignment','center');
%    set(gca, 'YDir','reverse','yticklabel',num2str(''),'xticklabel',num2str(''));
%    axis([50 650 40 400])
%    str = 'Social Approach. Example Group '
%    group = whichGroup(analysis.MouseNum)
%    title({str, group });
%    legend('Mouse Location');
end   
 %%   
% 8 8 6 6
data = [group0_SA, group0_empty, group1_SA, group1_empty];
g = {'f0','f0','f0','f0','f0','f0','f0','f0',...
    's0','s0','s0','s0','s0','s0','s0','s0',...
    'f1','f1','f1','f1','f1','f1',...
    's1','s1','s1','s1','s1','s1',};
[p, tbl, stats] = anova1(data,g);
Fstat = tbl{2,5};
multcomp = multcompare(stats);

addpath(genpath('Z:\Rodent Data\Wide Field Microscopy\VPA_Mesoscale_Analysis'));
fp = fig_params_vpa; 
rng('default');
group0_SA_pos = 1+rand(length(group0_SA),1)/2-0.25;
group0_empty_pos = 2+rand(length(group0_empty),1)/2-0.25;
group1_SA_pos = 3+rand(length(group1_SA),1)/2-0.25; 
group1_empty_pos = 4+rand(length(group1_empty),1)/2-0.25; 

figure('position',[680   558   240   271]); hold on;

b = bar([nanmean(group0_SA),nanmean(group0_empty) nanmean(group1_SA),nanmean(group1_empty)],'FaceColor','flat','FaceAlpha',0.5,'EdgeColor',[1 1 1]);    
b.CData(1,:) = [.5 0 .5];
b.CData(2,:) = [0 .5 0];
b.CData(3,:) = [.5 0 .5];
b.CData(4,:) = [0 .5 0];

plot(group0_SA_pos,group0_SA,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group0_empty_pos,group0_empty,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)  
plot(group1_SA_pos,group1_SA,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group1_empty_pos,group1_empty,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot) 

sem_group0_SA = std(group0_SA) / sqrt(length(group0_SA));
sem_group0_empty = std(group0_empty)/ sqrt(length(group0_empty));
sem_group1_SA = std(group1_SA) / sqrt(length(group1_SA));
sem_group1_empty = std(group1_empty)/ sqrt(length(group1_empty));

errorbar(1,nanmean(group0_SA),sem_group0_SA,'LineWidth',1.5,'Color','k');
errorbar(2,nanmean(group0_empty),sem_group0_empty,'LineWidth',1.5,'Color','k');
errorbar(3,nanmean(group1_SA),sem_group1_SA,'LineWidth',1.5,'Color','k');
errorbar(4,nanmean(group1_empty),sem_group1_empty,'LineWidth',1.5,'Color','k');


pf0s0 = multcomp(1,6);
temp_f0s0 = max(horzcat(1,group0_SA,group0_empty));
line([1,2],[temp_f0s0+temp_f0s0*0.1,temp_f0s0+temp_f0s0*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(1.5, temp_f0s0+temp_f0s0*0.125,sprintf(str,pf0s0),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

pf1s1 = multcomp(6,6);
temp_f1s1 = max(horzcat(1,group1_SA,group1_empty));
line([3,4],[temp_f1s1+temp_f1s1*0.1,temp_f1s1+temp_f1s1*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3.5, temp_f1s1+temp_f1s1*0.125,sprintf(str,pf1s1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

pf0f1 = multcomp(2,6);
temp_f0f1 = max(horzcat(1,group0_SA,group1_empty));
line([1,3],[temp_f0f1+temp_f0f1*0.02,temp_f0f1+temp_f0f1*0.02],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(2, temp_f0f1+temp_f0f1 *0.045,sprintf(str,pf0f1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

ps0s1 = multcomp(5,6);
temp_s0s1 = max(horzcat(1,group0_SA,group1_empty));
line([2,4],[temp_s0s1*.9,temp_s0s1*.9],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3, temp_s0s1*.93,sprintf(str,ps0s1),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');

fp.FormatAxes(gca);
set(gca,'Clipping','off','box','off');   
set(gca,'xtick',[1.5, 3.5],'xticklabel',{'Group 0','Group 1'},'xticklabelrotation',90,'FontSize',10,'xlim',[0.25 5])
ylabel('Time Spent (sec)','FontSize',12)


%% Entrences to each container

data = [group0_entrencesSA, group0_entrencesSN, group1_entrencesSA, group1_entrencesSN];
g = {'f0','f0','f0','f0','f0','f0','f0','f0',...
    's0','s0','s0','s0','s0','s0','s0','s0',...
    'f1','f1','f1','f1','f1','f1',...
    's1','s1','s1','s1','s1','s1',};
[p, tbl, stats] = anova1(data,g);
Fstat = tbl{2,5};
multcomp = multcompare(stats);

addpath(genpath('Z:\Rodent Data\Wide Field Microscopy\VPA_Mesoscale_Analysis'));
fp = fig_params_vpa; 
rng('default');
group0_SA_pos = 1+rand(length(group0_entrencesSA),1)/2-0.25;
group0_empty_pos = 2+rand(length(group0_entrencesSN),1)/2-0.25;
group1_SA_pos = 3+rand(length(group1_entrencesSA),1)/2-0.25; 
group1_empty_pos = 4+rand(length(group1_entrencesSN),1)/2-0.25; 

figure('position',[680   558   240   271]); hold on;

b = bar([nanmean(group0_entrencesSA),nanmean(group0_entrencesSN) nanmean(group1_entrencesSA),nanmean(group1_entrencesSN)],'FaceColor','flat','FaceAlpha',0.5,'EdgeColor',[1 1 1]);    
b.CData(1,:) = [.5 0 .5];
b.CData(2,:) = [0 .5 0];
b.CData(3,:) = [.5 0 .5];
b.CData(4,:) = [0 .5 0];

plot(group0_SA_pos,group0_entrencesSA,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group0_empty_pos,group0_entrencesSN,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)  
plot(group1_SA_pos,group1_entrencesSA,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group1_empty_pos,group1_entrencesSN,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot) 

sem_group0_SA = std(group0_entrencesSA) / sqrt(length(group0_entrencesSA));
sem_group0_empty = std(group1_entrencesSA)/ sqrt(length(group1_entrencesSA));
sem_group1_SA = std(group1_entrencesSA) / sqrt(length(group1_entrencesSA));
sem_group1_empty = std(group1_entrencesSN)/ sqrt(length(group1_entrencesSN));

errorbar(1,nanmean(group0_entrencesSA),sem_group0_SA,'LineWidth',1.5,'Color','k');
errorbar(2,nanmean(group0_entrencesSN),sem_group0_empty,'LineWidth',1.5,'Color','k');
errorbar(3,nanmean(group1_entrencesSA),sem_group1_SA,'LineWidth',1.5,'Color','k');
errorbar(4,nanmean(group1_entrencesSN),sem_group1_empty,'LineWidth',1.5,'Color','k');


pf0s0 = multcomp(1,6);
temp_f0s0 = max(horzcat(1,group0_entrencesSA,group0_entrencesSN));
line([1,2],[temp_f0s0+temp_f0s0*0.1,temp_f0s0+temp_f0s0*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(1.5, temp_f0s0+temp_f0s0*0.125,sprintf(str,pf0s0),'Rotation',0,'FontSize',10,'HorizontalAlignment','center');

pf1s1 = multcomp(6,6);
temp_f1s1 = max(horzcat(1,group1_entrencesSA,group1_entrencesSN));
line([3,4],[temp_f1s1+temp_f1s1*0.1,temp_f1s1+temp_f1s1*0.1],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3.5, temp_f1s1+temp_f1s1*0.125,sprintf(str,pf1s1),'Rotation',0,'FontSize',10,'HorizontalAlignment','center');

pf0f1 = multcomp(2,6);
temp_f0f1 = max(horzcat(1,group0_entrencesSA,group1_entrencesSN));
line([1,3],[temp_f0f1+temp_f0f1*0.02,temp_f0f1+temp_f0f1*0.02],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(2, temp_f0f1+temp_f0f1 *0.045,sprintf(str,pf0f1),'Rotation',0,'FontSize',10,'HorizontalAlignment','center');

ps0s1 = multcomp(5,6);
temp_s0s1 = max(horzcat(1,group0_entrencesSA,group1_entrencesSN));
line([2,4],[temp_s0s1*.9,temp_s0s1*.9],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(3, temp_s0s1*.93,sprintf(str,ps0s1),'Rotation',0,'FontSize',10,'HorizontalAlignment','center');

fp.FormatAxes(gca);
set(gca,'Clipping','off','box','off');   
set(gca,'xtick',[1.5, 3.5],'xticklabel',{'Group 0','Group 1'},'xticklabelrotation',90,'FontSize',10,'xlim',[0.25 5])
ylabel('# Entrences','FontSize',12)





