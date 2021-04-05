savedir = 'Z:\Users\Kennedy\thesis\figures';
addpath(genpath('Z:\Rodent Data\Wide Field Microscopy\VPA_Mesoscale_Analysis'));
fp = fig_params_vpa; 
group = %KENNEDY PUT IN THE vector of GROUPs here (1 or 0) 
rng('default');
group0_pos = 1+rand(sum(group==0),1)/2-0.25;
group1_pos = 2+rand(sum(group==1),1)/2-0.25; %generate random positions for jitter plot
figure('position',[680   558   240   271]); hold on;
group1 = %PUT THE Vector of SHANK animals DATA HERE
group0 = %put the vector of CONTORL ANIMALS HERE
b = bar([nanmean(group0),nanmean(group1)],'FaceColor','flat','FaceAlpha',0.5,'EdgeColor',[1 1 1]);    
b.CData(1,:) = [fp.c_sal_gray];
b.CData(2,:) = [fp.c_vpa_gray];
plot(group0_pos,group0,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)
plot(group1_pos,group1,'.','markersize',fp.m_markersize/1.5,'color',fp.c_dot)      
sem_group0 = std(group_0(:,2)) / sqrt(length(group_0(:,2)));
sem_group1 = std(group_1(:,2)) / sqrt(length(group_1(:,2)));
errorbar(1,nanmean(group0),sem_group0,'LineWidth',1.5,'Color','k');
errorbar(2,nanmean(group1),sem_group1,'LineWidth',1.5,'Color','k');
[p,~] = ranksum(group0,group1);
temp = max(cat(1,group0,group1));
line([1,2],[temp+temp*0.025,temp+temp*0.025],'linewidth',1.5,'color','k');
str = 'p = %0.2g';
text(1.5, temp+temp*0.15,sprintf(str,p),'Rotation',0,'FontSize',7,'HorizontalAlignment','center');
fp.FormatAxes(gca);
set(gca,'Clipping','off','box','off');   
set(gca,'units','centimeters','position',[2 2 1.25 3])
set(gca,'xtick',[1,2],'xticklabel',{'Group 0','Group 1'},'xticklabelrotation',90,'xlim',[0.25 2.75])
ylabel('')
set(gca,'LineWidth',2)
handles = get(groot, 'Children');
fp.SaveFigs(handles,'-svg','IndividualBehavioralTests',savedir,1); close all