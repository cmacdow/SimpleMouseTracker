function BatchProcess(toProcess,varargin)

%Camden MacDowell 2021. 
%target_dir is a cell array of directories to process

%Add paths
if ispc
    addpath(genpath('Z:\Projects\Cortical Dynamics\Mouse Models of Autism\Analysis Code\SimpleMouseTracker'));
else
    addpath(genpath('/jukebox/buschman/Projects/Cortical Dynamics/Mouse Models of Autism/Analysis Code/SimpleMouseTracker'));    
end

%% set options
opts.overwrite = 1; %moving window duration (in s)
opts.configStr = '_batchConfig.mat';
opts.algorithm = 'MiceMovieAnalyzerCJM_2018_batch';
opts.save_dir = 'Z:\Projects\Cortical Dynamics\Mouse Models of Autism\Behavioral Analysis\tobemoved';
opts.cropmovie = 0; 
opts.isjbp =1;
opts = ParseOptionalInputs(opts,varargin);

%% Process
%if directory process all files, otherwise process the single file
if isfolder(toProcess)
    %get files to process
    file_list = GrabFiles(opts.configStr, 0, toProcess);
else
    file_list = {toProcess};
end

%Counter for failed analysis files
fail_cnt = 1;
tic
%File Processing Loop
Not_processed = {};
for cur_fn = 1:length(file_list)
    load(file_list{cur_fn})  
    %remove anything done on a mac
    if ~isempty(regexp(Movie_fn,'Volumes','once'))
       Movie_fn = strrep(Movie_fn,'/Volumes/buschman/','Z:\');
       Movie_fn = strrep(Movie_fn,'/','\');
    end    
    if ~ispc %%is spock then convert to unix path
        Movie_fn = ConvertToBucketPath(Movie_fn,Movie_fn(1:3));
    end
    try 
        if opts.isjbp %parse by the section
            [movie_path, movie_name] = fileparts(file_list{cur_fn});
            movie_name = erase(movie_name,'_batchConfig');
        else
            [movie_path, movie_name] = fileparts(Movie_fn);
        end
        if isempty(opts.save_dir) %save in same directory as movie            
            save_fn=[movie_path filesep movie_name,'_AnalysisResults_batch', '.mat'];            
        else %save in target directory            
            save_fn=[opts.save_dir filesep movie_name,'_AnalysisResults_batch', '.mat'];
        end
        if opts.overwrite ==0 &&  exist(save_fn, 'file') == 2 %overwrite option to avoid re-analyzing the same files
            fprintf('\n\tFile %d has already been processed so skipping that file...\n',cur_fn)
            continue
        else
            if ispc %run using the usual function
                fprintf('\nCurrently Processing File %d out of %d...\n',cur_fn,length(file_list))
                fprintf('\nFileName %s\n',Movie_fn)
                switch opts.algorithm
                    case 'MiceMovieAnalyzerCJM_2018_batch'
                        [MF_indx,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,...
                        LastFrame]=MiceMovieAnalyzerCJM_2018_batch(Movie_fn,...
                        StartingFrame,EndingFrame,AllExcludedAreas,CompartmentsPositions,...
                        InteractionZones,ThresholdValue,MousePixelSize,dsFactor);
                    case 'MiceMovieAnalyzerCJM_2018_derivative_batch'
                        [MF_indx,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,...
                        LastFrame]=MiceMovieAnalyzerCJM_2018_derivative_batch(Movie_fn,...
                        StartingFrame,EndingFrame,AllExcludedAreas,CompartmentsPositions,...
                        InteractionZones,ThresholdValue,MousePixelSize,dsFactor);
                    otherwise 
                        error('unknown processing algorithm')
                end
                save(save_fn,'Movie_fn','LastFrame','firstFrame',...
                'AllExcludedAreas','CompartmentsPositions','InteractionZones',...
                'MouseLoc','InteractionTimes','CompartmentTimes','ThresholdValue',...
                'StartingFrame','EndingFrame','MF_indx',...
                'AnalysisDuration','MouseNum','ExpType','dsFactor','opts');
                if opts.cropmovie
                   DynamicCropping(save_fn)
                end
                
            else %use spock compatible version
                fprintf('\nCurrently Processing File %d out of %d...\n',cur_fn,length(file_list))
                fprintf('\nFileName %s\n',Movie_fn)
                fprintf('\nUsing Spock Compatible Version \n')
                [MF_indx,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,...
                LastFrame]=MiceMovieAnalyzerCJM_2018_spock(Movie_fn,...
                StartingFrame,EndingFrame,AllExcludedAreas,CompartmentsPositions,...
                InteractionZones,ThresholdValue,MousePixelSize,dsFactor);
                save(save_fn,'Movie_fn','LastFrame','firstFrame',...
                'AllExcludedAreas','CompartmentsPositions','InteractionZones',...
                'MouseLoc','InteractionTimes','CompartmentTimes','ThresholdValue',...
                'StartingFrame','EndingFrame','MF_indx',...
                'AnalysisDuration','MouseNum','ExpType','dsFactor','opts');
            end
                
        end
        fprintf('\n\n Finished File %d, Elapsed Time: %0.2g\n',cur_fn,toc/60)
    catch
        fprintf('\n\n Skipping File %d, Elapsed Time: %0.2g\n',cur_fn,toc/60)
        Not_processed{fail_cnt} = file_list{cur_fn};
        fail_cnt = fail_cnt +1; 
        continue
    end    
end
fprintf('\nCompleted Batch Processing of %d files \n Elapsed Time: %0.2g\n',length(file_list),toc/60)

%Let the user know if any files were not processed due to errors
if isempty('Not_processed')
    fprintf('\n%d Errors Occured During Batch Processing\n',length(Not_processed))
    fprintf('\n The Following files were not processed:\n')
    for np = 1:length(Not_processed)
        fprintf('%s \n',Not_processed{np});
    end
end

end