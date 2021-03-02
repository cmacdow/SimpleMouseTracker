function  [MF_indx,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,LastFrame]=MiceMovieAnalyzerCJM_2018_spock2(Movie_fn,StartingFrame,EndingFrame,AllExcludedAreas,CompartmentsPositions,InteractionZones,ThresholdValue,MousePixelSize,dsFactor)
   %%%%% The purpose of this function is to analyze the behavioral data.
   %%%%% It can evaluate general features about a single mouse
   %%%%% behavior, such as location and its derivatives.
   %%%%% It is also usefull for analyzing social recognition paradigms
   %%%%% and evaluate the time spent near a noval versus familiar conspecifics.
   
  MissedFrame =0;
  MouseLoc=[];
  InteractionTimes=cell(1,2);
  CompartmentTimes=cell(1,3);
  MF_indx(1) = StartingFrame;  
  fprintf('starting')
  
  %get file info
  [temppath,tempfn] = fileparts(Movie_fn);       
  fnCOUNT =0;
  N = size(dir([temppath,filesep,tempfn,'*.jpg']),1);
  
  for k=1:N
     fnCOUNT=fnCOUNT+1;
     cdataBW_ThresholdValue = load([temppath filesep tempfn,sprintf('%d.mat',fnCOUNT)],'cdataBW_ThresholdValue');    
     cdataBW_ThresholdValue=cdataBW_ThresholdValue.cdataBW_ThresholdValue;
     cdataWB_ThresholdValue=zeros(size(cdataBW_ThresholdValue,1),size(cdataBW_ThresholdValue,2));
     cdataWB_ThresholdValue(find(cdataBW_ThresholdValue==0))=1;
     Clean_cdataWB_ThresholdValue = bwareaopen(cdataWB_ThresholdValue, MousePixelSize);     
     
     %%%%% exclude pixels that were excluded from the image by the user
     if exist('AllExcludedAreas')
         for i=1:length(AllExcludedAreas)
               AreaToExclude=[];
               AreaToExclude=AllExcludedAreas{1,i}; 
               for j=1:size(AreaToExclude,1)
                  Clean_cdataWB_ThresholdValue(AreaToExclude(j,1),AreaToExclude(j,2))=0;
                  Clean_cdataWB_ThresholdValue(AreaToExclude(j,1),AreaToExclude(j,2))=0;
               end 
         end
     else
     end

     %%%%% look for boundaries of the mouse with high and low thresholds
     BoundariesWB_Threshold = bwboundaries(Clean_cdataWB_ThresholdValue);
     try
        BoundariesSizes_Theshold=[];
        for i=1:size(BoundariesWB_Threshold,1)
           BoundariesSizes_Theshold=[BoundariesSizes_Theshold,size(BoundariesWB_Threshold{i,1},1)];
        end
        MouseBoundary_Threshold=BoundariesWB_Threshold{find(BoundariesSizes_Theshold==max(BoundariesSizes_Theshold)),1};
        
     catch
         MouseBoundary_Threshold=[];
         
     end

     %%%%% Find the boarders of the interaction areas
     if k==StartingFrame
        for i=1:length(InteractionZones)
           InteractionPixels=[];
           InteractionPixels=InteractionZones{1,i}; 
           InteractionAreaOnFrame=zeros(size(cdataBW_ThresholdValue,1),size(cdataBW_ThresholdValue,2));
           for j=1:size(InteractionPixels,1)
              InteractionAreaOnFrame(InteractionPixels(j,1),InteractionPixels(j,2))=255;  
           end 
           se = strel('disk',1); %Dilate to include the pixel thick line
           InteractionAreaOnFrame=imdilate(InteractionAreaOnFrame,se);
           InteractionBoundariesPixels=bwboundaries(InteractionAreaOnFrame);
           if ~isempty(InteractionZones{1,i})
              AllInteractionBoundariesPixels{1,i}=InteractionBoundariesPixels{1,1};
           end
        end 
        firstFrame=cdataBW_ThresholdValue; %%%%% This parameter is saved for returning the first image of the analysis for presentation requirments 
     end

     
     %%%%% collect the 'MouseLocationCenterOfBody' according to the lowThreshold BW conversion and look for its location
    %%%%% within the different compartments 'CompartmentsPositionsList'
   
    if ~isempty(MouseBoundary_Threshold)
       MouseLoc=[MouseLoc; round(mean(MouseBoundary_Threshold(:,2))),round(mean(MouseBoundary_Threshold(:,1)))];
       for i=1:length(CompartmentsPositions)
          Compartment=[];
          Compartment=CompartmentsPositions{1,i}; 
          if ~isempty(Compartment)
             if find(Compartment(find(Compartment(:,1)==round(mean(MouseBoundary_Threshold(:,1)))),2)==round(mean(MouseBoundary_Threshold(:,2))))
                CompartmentTimes{1,i}=[[CompartmentTimes{1,i}],k]; 
             end
          end
       end
    end

    
    %%%%% collect the 'MouseLocationCenterOfBody' according to the Threshold BW conversion and look for its location
    %%%%% within the different Interaction Zones'
    
    if ~isempty(MouseBoundary_Threshold)
%        MouseLoc=[MouseLoc; round(mean(MouseBoundary_Threshold(:,2))),round(mean(MouseBoundary_Threshold(:,1)))];
       for i=1:length(InteractionZones)
          Zone=[];
          Zone=InteractionZones{1,i}; 
          if ~isempty(Zone)
             if find(Zone(find(Zone(:,1)==round(mean(MouseBoundary_Threshold(:,1)))),2)==round(mean(MouseBoundary_Threshold(:,2))))
                InteractionTimes{1,i}=[[InteractionTimes{1,i}],k]; 
             end
          end
       end
    end
  
         
    if isempty(MouseBoundary_Threshold)  %%%%% activated when the algorithm did not find the mouse
        %Have The Algorhtyhm assume the animal was in the same position as
        %the previous frame (this will help on frames where the animal
        %climbes and gets too small to be recognized by the image. 
        MouseLoc = [MouseLoc; MouseLoc(end,1),MouseLoc(end,2)];
        MissedFrame = MissedFrame+1;
        MF_indx(MissedFrame) = k;
 
    end
     
    TempNameStartPoint=strfind(Movie_fn, '\');
    if mod(k,round(0.01*EndingFrame))==0
        fprintf('\t%g%% Complete\n', round(k./EndingFrame*100,2));
    end

  %delete the frame 
  delete([temppath filesep tempfn,sprintf('%d.mat',fnCOUNT)]);
  end %Frame loop
  
  clear Film
  LastFrame=k;
  close all
  
end
  
