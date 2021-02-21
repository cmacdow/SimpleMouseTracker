function sex = whatSex(mouse_num,varargin)
%Define options
opts.TableFile = 'Cohort2_Animals.mat';
opts.LitterFile = 'Litters.xlsx';
opts.MouseNumColumn = 1; %column of mouse numbers on excel sheet
opts.SexColumn = 3; %column on the excel sheet
opts.TableName = 'keyTable';
opts.MotherNumColumn = 'MouseNumber';
opts.DoseColumn = 'Instructions';
opts.VPA_String = {'Give VPA'};
if ispc
    opts.BaseDir = 'Z:\Users\Camden\Projects\VPA Model\Behavioral and Developmental Assessments\Behavior Data\Cohort 2';
else
    opts.BaseDir = '/Volumes/Buschman/Users/Camden/Projects/VPA Model/Behavioral and Developmental Assessments/Behavior Data/Cohort 2';
end
%%
%Process optional inputs
if mod(length(varargin), 2) ~= 0, error('Must pass key/value pairs for options.'); end
for i = 1:2:length(varargin)
    try
        opts.(varargin{i}) = varargin{i+1};
    catch
        error('Couldn''t set option ''%s''.', varargin{2*i-1});
    end
end

%% Load MouseNum --> LitterNum file and find each passed mouse litter number. 

%load litter ket data from the excel file 
[lkdata] = xlsread([opts.BaseDir filesep opts.LitterFile]);

%Preallocate
sex = nan(1,length(mouse_num));

for cur_mouse = 1:length(mouse_num)
    %find current mouse row
    row = find(lkdata(:,opts.MouseNumColumn) == mouse_num(cur_mouse),1);
    if isempty(row)
        error('Mouse %d is not in excel sheet. Please double check number %d in input list',mouse_num(cur_mouse),cur_mouse)
    end 
    sex(cur_mouse) = lkdata(row,opts.SexColumn);
end

%1 = female, 0 = male
end











