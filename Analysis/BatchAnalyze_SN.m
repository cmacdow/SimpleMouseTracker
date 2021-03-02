%% DEFINTE OPTS
clear
clc
addpath('Z:\Users\Camden\Projects\VPA Model\Behavioral and Developmental Assessments\Analysis Code') %add to path the lcoation of the whatsex function
addpath('Z:\Users\Camden\Projects\VPA Model\Behavioral and Developmental Assessments\Analysis Code\barwitherr');

opts.fps = 30; 
opts.index = 1; %if you want to chart is as index (1) or percent of time spent in SA area (0);
opts.verbose = 1; 
opts.savefile = 0;
opts.savefig = 1; 
%Get list of all Processed Data files
% target_dir = '/Volumes/buschman/Users/Camden/Projects/VPA Model/Behavioral and Developmental Assessments/Behavior Data/Cohort 2/Adult Testing/Three Chamber Videos_AVIs_Analyzed';
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
data_fns = dir('*_SN_AnalysisResults_batch.mat');
if isempty(data_fns)   %Throw and Error if no batch config files
    warning('\nNo Results data files in selected directory %s\n',target_dir);
end
data_fns = fullfile(pwd, {data_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

%Preallocate structure
SACombined = struct('MouseNum', cell(length(data_fns),1),...
    'MouseSex', cell(length(data_fns),1),'MouseGroup', cell(length(data_fns),1),...
    'SAComp', cell(length(data_fns),1),'StrComp', cell(length(data_fns),1),...
    'SAInt', cell(length(data_fns),1),'StrInt', cell(length(data_fns),1),....
    'DroppedFrames', cell(length(data_fns),1));

for cur_fn = 1:length(data_fns) %file loop
    load(data_fns{cur_fn});
    %Populate the combined data structure
    SACombined(cur_fn).MouseNum = MouseNum;
    SACombined(cur_fn).MouseSex = whatSex(MouseNum);
    SACombined(cur_fn).MouseGroup = isVPA_cm(MouseNum);
    SACombined(cur_fn).MouseGenotype = whatGenotype(MouseNum); 
    SACombined(cur_fn).SAComp = CompartmentTimes{1} - StartingFrame; %Need to subtract the starting frame which changes between animals
    SACombined(cur_fn).StrComp = CompartmentTimes{2} - StartingFrame;
    SACombined(cur_fn).SAInt = InteractionTimes{1} - StartingFrame;
    SACombined(cur_fn).StrInt = InteractionTimes{2} - StartingFrame;
    SACombined(cur_fn).DroppedFrames = length(MF_indx);    
    %Quick gut check that the analysis file is 10 minutes long
    indx = 1;
    if size(firstFrame) == [480 640 3]
       MouseLoc = MouseLoc/2; 
    elseif size(firstFrame) == [240 320 3]
    else
        warning('unknown frame size for file',cur_fn)
    end
    
    for i = 1:9000-2
        indx = indx + 2; 
        velocity(i) = pdist2(MouseLoc(indx,:),MouseLoc((indx-2),:),'euclidean');
    end
    SACombined(cur_fn).velocity = velocity;  
    %Calculate the number of transitions
    t = zeros(1,length(MouseLoc)); % For transitions, zero = middle region
    trans1 = [zeros(1,15),ones(1,15)]; %middle to sta this way it requires at least a second outside of the regions to count as a transition (speedy little devils so don't want to do any more than that)
    trans2 = [zeros(1,15),ones(1,15)*2]; %middle to empty
    t = zeros(1,length(MouseLoc)-1); %zero = middle region
    t(SACombined(cur_fn).SAComp+1) = 1; %1 = SA Comp Add one to make it indexed correctly (zero indexed initially); 
    t(SACombined(cur_fn).StrComp+1)=2; %2 = Empty Comp
    temp1 = strfind(t,trans1);
    temp2 = strfind(t,trans2);
    SACombined(cur_fn).numTransitions = length(temp1)+length(temp2);
    SACombined(cur_fn).reEnterSA = length(temp1)-length(temp2);
    if SACombined(cur_fn).reEnterSA <= 0
        SACombined(cur_fn).reEnterSA = 0;
    end
    SACombined(cur_fn).reEnterStr = length(temp2)-length(temp1);
    if SACombined(cur_fn).reEnterStr <= 0
        SACombined(cur_fn).reEnterStr = 0;
    end
    clear temp1 temp2 
    if round(length(MouseLoc)/(opts.fps*60),2) ~= 10;
        warning('Check analysis duration for mouse %d',SACombined(cur_fn).MouseNum)
    end
    clearvars -except data_fns cur_fn SACombined opts
end %file loop


if opts.savefile
    SNCombined = SACombined;
    save('SNCombined.mat','SNCombined')
end
%% %% COMPARTMENT TOTAL SOCIAL NOVELTY PLOT
if opts.verbose 
    bin = 15;

f1 = figure; hold on
subplot(121); hold on
SAIndex = NaN(length(SACombined),2);
for cur_mouse = 1:length(SACombined)
    grp = SACombined(cur_mouse).MouseGroup + 1; %split into groups of VPA = 2, SAL = 1; 
    if opts.index ==1;
        SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).StrComp)./(length(SACombined(cur_mouse).StrComp)+length(SACombined(cur_mouse).SAComp));    
    elseif opts.index ==2; 
        SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).StrComp)./(length(SACombined(cur_mouse).SAComp));    
    else
        SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).StrComp)/30;%Frame Rate    
        NonSATime(cur_mouse,grp) = length(SACombined(cur_mouse).SAComp)/30;
    end
    
end
if opts.index == 1;
    SEM = nanstd(SAIndex)/sqrt(length(SAIndex));
    means = nanmean(SAIndex);
    h = barwitherr(SEM, means); hold on;
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',{'SAL','VPA'})
    ylabel('SN Index')
elseif opts.index ==2; 
    SEM = nanstd(SAIndex)/sqrt(length(SAIndex));
    means = nanmean(SAIndex);
    h = barwitherr(SEM, means); hold on;
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',{'SAL','VPA'})
    ylabel('Time spent in social chamber (sec)')
else
    SEM = nanstd(SAIndex)/sqrt(length(SAIndex));
    SEM2 = nanstd(NonSATime)/sqrt(length(NonSATime));
    means2 = nanmean(NonSATime); 
    means = nanmean(SAIndex);
    h = barwitherr([SEM SEM2], [means means2]); hold on;
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',{'SAL','VPA'})
    ylabel('Time spent in social chamber (sec)')
end

set(h(1),'FaceColor',[0.7 0.7 0.7]);
for cur_mouse = 1:length(SACombined)
    grp = SACombined(cur_mouse).MouseGroup + 1;
    xval = [(1.125-rand(1)/4),(2.125-rand(1)/4)]; %Generate the x value for the scatter plot (have a little random to distribute it horizontally)
    if SACombined(cur_mouse).MouseGroup == 1; %make vpa red
        if SACombined(cur_mouse).MouseSex ==1; % females = 0
            scatter(xval(grp),SAIndex(cur_mouse,grp),'r','o')
        else
            scatter(xval(grp),SAIndex(cur_mouse,grp),'r','*')
        end
    else %make sal blue
        if SACombined(cur_mouse).MouseSex ==1; %females = 0
            scatter(xval(grp),SAIndex(cur_mouse,grp),'b','o')
        else
            scatter(xval(grp),SAIndex(cur_mouse,grp),'b','*')
        end
    end       
end
title('Compartment: Total Time')
% COMPARMENT SOCIAL INDEX OVER TIME PLOT
subplot(122); hold on
%Preallocate Array
clear SAIndex
SAIndex = NaN(length(SACombined),2);

%Get the mean and SEMs for each group for each 30sec bin
for epoch = 1:20 %Increment Loop
    FrameInc = bin*30; 
    if epoch == 1
        startFrame = 1;
    else
        startFrame = (epoch*bin*30)-FrameInc;
    end
    for cur_mouse = 1:length(SACombined) %Mouse loop
        grp = SACombined(cur_mouse).MouseGroup + 1; %split into groups of VPA = 2, SAL = 1;SACombined(cur_mouse).SAComp 
        dur_social = length(find(SACombined(cur_mouse).SAComp < (startFrame+FrameInc) & SACombined(cur_mouse).SAComp >= startFrame));
        dur_Str = length(find(SACombined(cur_mouse).StrComp < (startFrame+FrameInc) & SACombined(cur_mouse).StrComp >=startFrame));
        if opts.index ==1;
            SAIndex(cur_mouse,grp)= dur_Str/(dur_social+dur_Str);
        elseif opts.index ==2;
            SAIndex(cur_mouse,grp)= dur_Str/(dur_social);
        else
            SAIndex(cur_mouse,grp)= dur_Str/FrameInc; %number of frames in an epoch
            NonSATime(cur_mouse,grp) = dur_social/FrameInc;
        end
        hold on
        if  grp ==1;  
            if SACombined(cur_mouse).MouseSex == 1; %make females in SAL cyan
                scatter(epoch,SAIndex(cur_mouse,grp),'c','.')
            else %make males SAL blue
                scatter(epoch,SAIndex(cur_mouse,grp),'b','.')
            end
        else
            if SACombined(cur_mouse).MouseSex == 1; %make females in VPA magenta
                scatter(epoch,SAIndex(cur_mouse,grp),'m','.')
            else %make males VPA red
                scatter(epoch,SAIndex(cur_mouse,grp),'r','.')
            end  
        end
    end %Mouse loop

    SEM(epoch,:) = nanstd(SAIndex)/sqrt(length(SAIndex));
    means(epoch,:) = nanmean(SAIndex);
end %Increment Loop

%Plot SAL
shadedErrorBar((1:length(means)),means(:,1)', SEM(:,1)','lineprops','b');
%Plot VPA
shadedErrorBar((1:length(means)),means(:,2)', SEM(:,2)','lineprops','r');

title('Compartment: By epoch')

if opts.savefig
    savefig(f1,'SocialNovelty.fig')
end

%% INTERACTION TOTAL SOCIAL NOVELTY PLOT
SAIndex = NaN(length(SACombined),2);
for cur_mouse = 1:length(SACombined)
    grp = SACombined(cur_mouse).MouseGroup + 1; %split into groups of VPA = 2, SAL = 1; 
    if opts.index ==1; 
        SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).StrInt)./(length(SACombined(cur_mouse).StrInt)+length(SACombined(cur_mouse).SAInt));    
    elseif opts.index ==2; 
        SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).StrInt)./(length(SACombined(cur_mouse).SAInt));    
    else
        SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).StrInt)./18000; %total time in frames
        NonSATime(cur_mouse,grp) = length(SACombined(cur_mouse).SAInt)./18000;
    end
end
f2 = figure; hold on
subplot(121); hold on
SEM = nanstd(SAIndex)/sqrt(length(SAIndex));
means = nanmean(SAIndex);
h = barwitherr(SEM, means); hold on;
set(gca,'XTick',[1,2])
set(gca,'XTickLabel',{'SAL','VPA'})
if opts.index
    ylabel('SN Index')
else
    ylabel('% Time spent in social chamber')
end
set(h(1),'FaceColor',[0.7 0.7 0.7]);
for cur_mouse = 1:length(SACombined)
    grp = SACombined(cur_mouse).MouseGroup + 1;
    xval = [(1.125-rand(1)/4),(2.125-rand(1)/4)]; %Generate the x value for the scatter plot (have a little random to distribute it horizontally)
    if SACombined(cur_mouse).MouseSex == 1; %make females red
        if SACombined(cur_mouse).MouseGenotype ==1; %WT
            scatter(xval(grp),SAIndex(cur_mouse,grp),'r','o')
        else
            scatter(xval(grp),SAIndex(cur_mouse,grp),'r','*')
        end
    else %make males blue
        if SACombined(cur_mouse).MouseGenotype ==1; %WT
            scatter(xval(grp),SAIndex(cur_mouse,grp),'b','o')
        else
            scatter(xval(grp),SAIndex(cur_mouse,grp),'b','*')
        end
    end     
end
title('Interaction: Total Time')
% Interaction SOCIAL INDEX OVER TIME PLOT
%Preallocate Array
clear SAIndex
SAIndex = NaN(length(SACombined),2);
subplot(122); hold on
%Get the mean and SEMs for each group for each 30sec bin
for epoch = 1:10 %Increment Loop
    FrameInc = bin*30; 
    if epoch == 1
        startFrame = 1;
    else
        startFrame = (epoch*bin*30)-FrameInc;
    end
    for cur_mouse = 1:length(SACombined) %Mouse loop
        grp = SACombined(cur_mouse).MouseGroup + 1; %split into groups of VPA = 2, SAL = 1;SACombined(cur_mouse).SAInt 
        dur_social = length(find(SACombined(cur_mouse).SAInt < (startFrame+FrameInc) & SACombined(cur_mouse).SAInt >= startFrame));
        dur_Str = length(find(SACombined(cur_mouse).StrInt < (startFrame+FrameInc) & SACombined(cur_mouse).StrInt >=startFrame));
        if opts.index ==1; 
            SAIndex(cur_mouse,grp)= dur_Str/(dur_social+dur_Str);
        elseif opts.index ==2; 
            SAIndex(cur_mouse,grp)= dur_Str/(dur_social);
        else
            SAIndex(cur_mouse,grp)= dur_Str/FrameInc; %/(dur_social+dur_Str);
            NonSATime(cur_mouse,grp) = dur_Soc/FrameInc;
        end
        
        hold on
        if  grp ==1;  
            if SACombined(cur_mouse).MouseSex == 1; %make females in SAL cyan
                scatter(epoch,SAIndex(cur_mouse,grp),'c','.')
            else %make males SAL blue
                scatter(epoch,SAIndex(cur_mouse,grp),'b','.')
            end
        else
            if SACombined(cur_mouse).MouseSex == 1; %make females in VPA magenta
                scatter(epoch,SAIndex(cur_mouse,grp),'m','.')
            else %make males VPA red
                scatter(epoch,SAIndex(cur_mouse,grp),'r','.')
            end  
        end
    end %Mouse loop

    SEM(epoch,:) = nanstd(SAIndex)/sqrt(length(SAIndex));
    means(epoch,:) = nanmean(SAIndex);
end %Increment Loop

title('Interaction: By epoch')
%Plot SAL
shadedErrorBar((1:length(means)),means(:,1)', SEM(:,1)','lineprops','g');
%Plot VPA
shadedErrorBar((1:length(means)),means(:,2)', SEM(:,2)','lineprops','r');
end %verbose section
%%




















