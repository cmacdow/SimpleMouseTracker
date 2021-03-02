%% DEFINTE OPTS
clear
clc
addpath('Z:\Users\Camden\Projects\VPA Model\Behavioral and Developmental Assessments\Analysis Code') %add to path the lcoation of the whatsex function
addpath('Z:\Users\Camden\Projects\VPA Model\Behavioral and Developmental Assessments\Analysis Code\barwitherr');
opts.fps = 30;
opts.savefig = 1; 
opts.savedata =1;
opts.index = 1;%if you want to chart is as index (1) or percent of time spent in SA area (0);
opts.verbose = 1; %Decide how chatty we want to be
%Get list of all Processed Data files
% target_dir = '/Volumes/buschman/Users/Camden/Projects/VPA Model/Behavioral and Developmental Assessments/Behavior Data/Cohort 2/Adult Testing/Three Chamber Videos_AVIs_Analyzed';
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);
data_fns = dir('*_HAB_AnalysisResults_batch.mat');
if isempty(data_fns)   %Throw and Error if no batch config files
    warning('\nNo Results data files in selected directory %s\n',target_dir);
end
data_fns = fullfile(pwd, {data_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

%Preallocate structure
SACombined = struct('MouseNum', cell(length(data_fns),1),...
    'MouseSex', cell(length(data_fns),1),'MouseGroup', cell(length(data_fns),1),...
    'SAComp', cell(length(data_fns),1),'EmptyComp', cell(length(data_fns),1),...
    'SAInt', cell(length(data_fns),1),'StrInt', cell(length(data_fns),1),....
    'DroppedFrames', cell(length(data_fns),1));




for cur_fn = 1:length(data_fns) %file loop
    load(data_fns{cur_fn});
    %Populate the combined data structure
    SACombined(cur_fn).MouseNum = MouseNum;
    SACombined(cur_fn).MouseSex = whatSex(MouseNum);
    SACombined(cur_fn).MouseGenotype = whatGenotype(MouseNum); 
    SACombined(cur_fn).MouseGroup = isVPA_cm(MouseNum);
    SACombined(cur_fn).SAComp = CompartmentTimes{1} - StartingFrame; %Need to subtract the starting frame which changes between animals
    SACombined(cur_fn).EmptyComp = CompartmentTimes{2} - StartingFrame;
    SACombined(cur_fn).DroppedFrames = length(MF_indx);    
    %Quick gut check that the analysis file is 10 minutes long
    indx = 1;
    if size(firstFrame) == [480 640 3]
       MouseLoc = MouseLoc/2; 
    elseif size(firstFrame) == [240 320 3]
    else
        warning('unknown frame size for file',cur_fn)
    end
    
    for i = 1:4500-2
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
    t(SACombined(cur_fn).EmptyComp+1)=2; %2 = Empty Comp
    temp1 = strfind(t,trans1);
    temp2 = strfind(t,trans2);
    SACombined(cur_fn).numTransitions = length(temp1)+length(temp2);
    SACombined(cur_fn).reEnterSA = length(temp1)-length(temp2);
    if SACombined(cur_fn).reEnterSA <= 0
        SACombined(cur_fn).reEnterSA = 0;
    end
    SACombined(cur_fn).reEnterEmptySN = length(temp2)-length(temp1);
    if SACombined(cur_fn).reEnterEmptySN <= 0
        SACombined(cur_fn).reEnterEmptySN = 0;
    end
    clear temp1 temp2 
    if round(length(MouseLoc)/(opts.fps*60),2) ~= 5
        warning('Check analysis duration for mouse %d',SACombined(cur_fn).MouseNum)
    end
    clearvars -except data_fns cur_fn SACombined opts
end %file loop

if opts.verbose
    f1 = figure; hold on
    SAIndex = NaN(length(SACombined),2);
    for cur_mouse = 1:length(SACombined)
        grp = SACombined(cur_mouse).MouseGroup + 1; %split into groups of VPA = 2, SAL = 1; 
        if opts.index ==1;
            SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).SAComp)./(length(SACombined(cur_mouse).EmptyComp)+length(SACombined(cur_mouse).SAComp));    
        elseif opts.index ==2;
            SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).SAComp)./(length(SACombined(cur_mouse).EmptyComp));    
        else
            SAIndex(cur_mouse,grp)= length(SACombined(cur_mouse).SAComp)/(300*opts.fps);%total time    
        end

    end
    SEM = nanstd(SAIndex)/sqrt(length(SAIndex));
    means = nanmean(SAIndex);
    h = barwitherr(SEM, means); hold on;
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',{'SAL','VPA'})
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
    title('Side Preference Habituation')
    ylabel(sprintf('Side Index \nSA Side / (SA+OtherSide)'))
    
end
    
    
if opts.savedata
    HABCombined = SACombined;
    save('HABcombined.mat','HABCombined')
end

if opts.savefig
    savefig(f1,'SidePreferenceHabituation.fig')
end