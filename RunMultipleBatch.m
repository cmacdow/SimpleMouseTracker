file_list = load('ToProcess_April03_2021_09_12.mat','file_list');
file_list2 = load('ToProcess_April03_2021_06_56.mat','file_list');

parfor i = 1:numel(file_list.file_list)
    BatchProcess(file_list.file_list{i},'isjbp',0);
end


parfor i = 1:numel(file_list2.file_list)
    BatchProcess(file_list2.file_list{i},'isjbp',1);
end
