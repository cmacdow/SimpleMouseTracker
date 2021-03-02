function Local_BatchProcess(ToProcessfn)

%% Parse the file paths
file_list = load(ToProcessfn,'file_list');
file_list=file_list.file_list;

parfor cur_fn = 1:numel(file_list)  
    BatchProcess(file_list{cur_fn});
end


end