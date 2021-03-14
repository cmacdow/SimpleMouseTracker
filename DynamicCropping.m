function DynamicCropping(analysis_fn,varargin)
%Camden MacDowell - timeless

%% set options
options.croprect = [-325,-325,650,650]; %size and centering of crop
options.sp_downsample = 0.5; %factor to spatially downsample by 
options.exlude_rois = 0; %boolean to nan out exluded regions in the original video
options = ParseOptionalInputs(options,varargin);

%% load and process data
%[analysis_fns, folder_list] = GrabFiles('batch');
load(analysis_fn);

%remove large jumps, iterate until no more found
jumpsize = cat(1, [0,0],abs(diff(MouseLoc))>=100);
MouseLoc(jumpsize==1)=NaN;
MouseLoc = fillmissing(MouseLoc,'nearest');

%now interate along smaller jumps
jumpsize =1;
while sum(jumpsize>0)
    jumpsize = cat(1, [0,0],abs(diff(MouseLoc))>=100);
    MouseLoc(jumpsize==1)=NaN;
    MouseLoc = fillmissing(MouseLoc,'linear');
end

%interpolate back out to the non downsampled video
MouseLocFull = cat(2,interp(MouseLoc(:,1),dsFactor),interp(MouseLoc(:,2),dsFactor));

%may need to cut final frame? Never happened but in case
if size(MouseLocFull,1)>(EndingFrame-StartingFrame+1)
    MouseLocFull = MouseLocFull(1:end-1,:);
elseif size(MouseLocFull,1)<(EndingFrame-StartingFrame+1)
    MouseLocFull(end+1,:) = MouseLocFull(end,:);
end

%shift forward by 0.5 seconds since it seems lacking
nshift = -15;
MouseLocFull_shift = circshift(MouseLocFull,nshift,1);
MouseLocFull_shift(end-abs(nshift)+1:end,:) = MouseLocFull(end-abs(nshift)+1:end,:);

%create mask using excluded pixels so DLC won't try to track those


%crop around animal and save new movie
Film = VideoReader(Movie_fn);
[~,Save_fn] = fileparts(Movie_fn);
[save_path] = fileparts(analysis_fn);
if ~isempty(save_path)
    Save_fn=[save_path filesep Save_fn '_cropped'];         
else
    Save_fn=[pwd filesep Save_fn '_cropped'];         
end
CroppedVideo = VideoWriter([Save_fn '.avi']);
CroppedVideo.FrameRate = Film.FrameRate;
open(CroppedVideo);

%create pad
h_pad = uint8(zeros(Film.Height,options.croprect(3),3));
v_pad = uint8(zeros(options.croprect(4),Film.Width+2*options.croprect(3),3));
COUNT = 1;
for k=StartingFrame:EndingFrame
   dataPad = read(Film,k); 
   %pad with 2x the size of the crop rectangle
   dataPad = cat(2,h_pad,dataPad,h_pad);
   dataPad = cat(1,v_pad,dataPad,v_pad);
   dataCrop = imcrop(dataPad,options.croprect+[MouseLocFull(COUNT,1)+size(h_pad,2),MouseLocFull(COUNT,2)+size(v_pad,1),0,0]);  
   %spatial downsample 
   dataCrop = imresize(dataCrop,options.sp_downsample);
   writeVideo(CroppedVideo,dataCrop);        
   COUNT = COUNT+1; %to deal with dsFactor
   if mod(k,round(0.01*((EndingFrame-StartingFrame))))==0
        fprintf('\t%g%% Complete\n', round(k./EndingFrame*100,2));
   end
end


close(CroppedVideo);    

