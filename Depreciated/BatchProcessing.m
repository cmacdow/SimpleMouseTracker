clear
clc
overwrite = 0; %overwrite previously analyzed files? (1) = yes
target_dir = uigetdir; %Select Directory to batch process
startdir = (pwd);
cd(target_dir);


config_fns = dir('*_batchConfig.mat');
if isempty(config_fns)   %Throw and Error if no batch config files
    warning('\nNo batch configurations in selected directory %s\n',target_dir);
end

config_fns = fullfile(pwd, {config_fns.name}); %Get full directory of the config files
cd(startdir); %Return to the original dir

%Counter for failed analysis files
fail_cnt = 1;
tic
%File Processing Loop
for cur_fn = 1:length(config_fns)
    load(config_fns{cur_fn})  
    try     
        save_fn=[Movie_fn '_' ExpType,'_AnalysisResults_batch', '.mat'];
        if overwrite ==0 &&  exist(save_fn, 'file') == 2 %overwrite option to avoid re-analyzing the same files
            fprintf('\n\tFile %d has already been processed so skipping that file...\n',cur_fn)
            continue
        else
            fprintf('\nCurrently Processing File %d out of %d...\n',cur_fn,length(config_fns))
            fprintf('\nFileName %s\n',Movie_fn)
            [MF_indx,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,...
            LastFrame]=MiceMovieAnalyzerCJM_2018_batch(Movie_fn,...
            StartingFrame,EndingFrame,AllExcludedAreas,CompartmentsPositions,...
            InteractionZones,ThresholdValue,MousePixelSize,dsFactor);
            save(save_fn,'Movie_fn','LastFrame','firstFrame',...
            'AllExcludedAreas','CompartmentsPositions','InteractionZones',...
            'MouseLoc','InteractionTimes','CompartmentTimes','ThresholdValue',...
            'StartingFrame','EndingFrame','MF_indx',...
            'AnalysisDuration','MouseNum','ExpType');
        end
    catch
        Not_processed{fail_cnt} = config_fns{cur_fn};
        fail_cnt = fail_cnt +1; 
        continue
    end
        
end
fprintf('\nCompleted Batch Processing of %d files \n Elapsed Time: %d\n',length(config_fns),toc/60)

%Let the user know if any files were not processed due to errors
if exist('Not_processed')
    fprintf('\n%d Errors Occured During Batch Processing\n',length(Not_processed))
    fprintf('\n The Following files were not processed:\n')
    for np = 1:length(Not_processed)
        fprintf('%s \n',Not_processed{np});
    end
end
    


