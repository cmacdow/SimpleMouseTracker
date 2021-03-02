function CreateProcessingList(configStr,local_bucket)

%Camden 2021 timeless. Lets a user create a list of directories that they
%want me to process on spock to avoid copy/pasting strings. 

%Dependencies: Needs to have SimpleMouseTracker repository added to MATLAB
%path 

%select folders to processes
if nargin <1; configStr='_batchConfig.mat'; end %name of the configuation files. Change this to load only specific names (i.e. 'EXPERIMENTTYPE_batchConfirm.mat');
if nargin <2; local_bucket = []; end %

%Confirm we are in correct directory (needs to be a 'ToProcess' subdir)
assert(logical(exist('PathsToProcess','dir')),'No ToProcess directory available to save file. Please check that you are located in the correct directory and that SimpleMouseTracker Repo is added to path')

%get files to process
[file_list]= GrabFiles(configStr, 1);

file_list_bucket = file_list;
for i = 1:numel(file_list)
    [file_list_bucket{i},local_bucket] = ConvertToBucketPath(file_list{i},local_bucket);
end

%convert to unix path for spock

cd([local_bucket,'Projects\Cortical Dynamics\Mouse Models of Autism\Analysis Code\SimpleMouseTracker\','PathsToProcess']);
save([pwd filesep 'ToProcess_' datestr(now,'mmmmdd_yyyy_HH_MM')],'file_list','file_list_bucket','configStr');

end


