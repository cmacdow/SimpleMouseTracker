function [file_bucket,local_bucket]= ConvertToBucketPath(file,local_bucket,spock_bucket)

if nargin <3 
     spock_bucket = '\jukebox\buschman\';
end

if isempty(local_bucket)
    local_bucket = input("\n What drive is bucket mapped to (for example, provide the string 'Z:\'): \n");
end


file_bucket = [spock_bucket erase(file,local_bucket)];
file_bucket= regexprep(file_bucket, '\','/');

end