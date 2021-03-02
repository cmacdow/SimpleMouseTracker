function Spock_BatchProcess(ToProcessfn)

%% Spock SetUp
% Open ssh connection
username = input(' Spock Username: ', 's');
password = passcode();
s_conn = ssh2_config('spock.princeton.edu',username,password);

%% Parse the file paths
load(ToProcessfn,'file_list_bucket','file_list');

for cur_fn = 1%:numel(file_list_bucket)        
    %include the substring used to allow rerunning subsets. 
    script_name = WriteBashScript(sprintf('batchprocess%d',cur_fn),'BatchProcess',{file_list_bucket{cur_fn}},{"'%s'"},...
        'sbatch_time',239,'sbatch_memory',10);  %239 is the 'max for 'short spock runs'

    %Run job
    response = ssh2_command(s_conn,...
        ['cd /jukebox/buschman/Projects/Cortical\ Dynamics/Mouse\ Models\ of\ Autism/Analysis\ Code/SimpleMouseTracker/Spock/ ;',... %cd to directory
        sprintf('sbatch %s',script_name)]); 
end

%close out connection
ssh2_close(s_conn);
clear username password sconn

end
    


