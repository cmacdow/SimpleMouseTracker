function  [MF_indx,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,LastFrame]=MiceMovieAnalyzerCJM_2018_derivative_batch(Movie_fn,StartingFrame,EndingFrame,AllExcludedAreas,CompartmentsPositions,InteractionZones,ThresholdValue,MousePixelSize,dsFactor)
   %%%%% The purpose of this function is to analyze the behavioral data.
   %%%%% It can evaluate general features about a single mouse
   %%%%% behavior, such as location and its derivatives.
   %%%%% It is also usefull for analyzing social recognition paradigms
   %%%%% and evaluate the time spent near a noval versus familiar conspecifics.
   %%%%% The addition in this algorism is for tracking the mouse nose and
   %%%%% directionality.
  %build exclude mask
   %%%%% exclude pixels that were excluded from the image by the user
     
  MissedFrame =0;
  MouseLoc=[];
  InteractionTimes=cell(1,2);
  CompartmentTimes=cell(1,3);
  %Film = VideoReader(Movie_fn);
  MF_indx(1) = StartingFrame;  
%   EndingFrame = StartingFrame+(600*30);
 Film = VideoReader(Movie_fn);
 se = strel('disk',MousePixelSize);
 
 %build exclude mask
 AreaToExclude = unique(cat(1,AllExcludedAreas{:}),'rows');
 mask = accumarray(AreaToExclude,ones(size(AreaToExclude,1),1),[Film.Height Film.Width]);
 if Film.NumFrame-EndingFrame<=(dsFactor+1)%need to make sure doesn't go to complete end
     EndingFrame = EndingFrame-dsFactor-1;
 end
  for k=StartingFrame:dsFactor:EndingFrame
     cdataRGB = read(Film,[k,k+dsFactor-1]);
     firstFrame=cdataRGB(:,:,:,1);
     cdataBW_ThresholdValue = zeros(size(cdataRGB,1),size(cdataRGB,2),dsFactor);
     Clean_cdataWB_ThresholdValue = zeros(size(cdataRGB,1),size(cdataRGB,2),dsFactor);
     for i = 1:dsFactor-1
        cdataBW_ThresholdValue(:,:,i) = sum(imbinarize(cdataRGB(:,:,:,i)-cdataRGB(:,:,:,i+1)),3);                
        %open to get rid of spot noise
        Clean_cdataWB_ThresholdValue(:,:,i) = bwareaopen(cdataBW_ThresholdValue(:,:,i), MousePixelSize*2); 
     end
     %close to seal mouse        
     Clean_cdataWB_ThresholdValue = imclose(sum(Clean_cdataWB_ThresholdValue,3),se);     
     Clean_cdataWB_ThresholdValue = sum(Clean_cdataWB_ThresholdValue,3);
     Clean_cdataWB_ThresholdValue(Clean_cdataWB_ThresholdValue>0)=1;
     cdataBW_ThresholdValue = sum(cdataBW_ThresholdValue,3);
     cdataBW_ThresholdValue(cdataBW_ThresholdValue>0)=1;
    
     %%%%% exclude pixels that were excluded from the image by the user
     Clean_cdataWB_ThresholdValue(mask==1)=0;

     %%%%% look for boundaries of the mouse with high and low thresholds
     BoundariesWB_Threshold = bwboundaries(Clean_cdataWB_ThresholdValue);
     if isempty(BoundariesWB_Threshold)
        MouseBoundary_Threshold=[];
        MouseLoc = [MouseLoc; MouseLoc(end,1),MouseLoc(end,2)];
        MissedFrame = MissedFrame+1;
        MF_indx(MissedFrame) = k;  
        
     else
         [~, max_index] = max(cellfun(@numel, BoundariesWB_Threshold));       
         MouseBoundary_Threshold = BoundariesWB_Threshold{max_index};
         MouseLoc=[MouseLoc; round(mean(MouseBoundary_Threshold(:,2))),round(mean(MouseBoundary_Threshold(:,1)))];
     end
        
    TempNameStartPoint=strfind(Movie_fn, '\');
    if mod(k,round(0.01*((EndingFrame-StartingFrame)/dsFactor)))==0
        fprintf('\t%g%% Complete\n', round(k./EndingFrame*100,2));
    end
  end %Frame loop
  
  clear Film
  LastFrame=k;
  close all
  
  
end
  
