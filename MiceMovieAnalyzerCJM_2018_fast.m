function  [MissedFrame,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,LastFrame]=MiceMovieAnalyzerCJM_2018_fast(Movie_fn,HandlesForGUIControls,StartingFrame,EndingFrame,AllExcludedAreas,CompartmentsPositions,InteractionZones,SaveMovie,ThresholdValue,MousePixelSize,dsFactor)
   %%%%% The purpose of this function is to analyze the behavioral data.
   %%%%% It can evaluate general features about a single mouse
   %%%%% behavior, such as location and its derivatives.
   %%%%% It is also usefull for analyzing social recognition paradigms
   %%%%% and evaluate the time spent near a noval versus familiar conspecifics.
   %%%%% The addition in this algorism is for tracking the mouse nose and
   %%%%% directionality.
   

global StopAnalysis
  MissedFrame =0;
  MouseLoc=[];
  InteractionTimes=cell(1,2);
  CompartmentTimes=cell(1,3);
  Film = VideoReader(Movie_fn);
 
  for k=StartingFrame:dsFactor:EndingFrame
  
     %%%%% open the image, convert it to black and white and clean it from noise 
     %%%%% High and low thresholds in this algorithm are used for detection
     %%%%% of the tail outside of the ellipse fitted to the mouse
     %%%%% boundaries. low threshold is for finding the ellipse and high
     %%%%% threshold is for finding the tail outside of the ellipse.
     cdataRGB = read(Film,k);
     cdataBW_ThresholdValue=im2bw(cdataRGB,ThresholdValue);
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
     
     %%%%% change the areas of the stimuli in the clean black and white
     %%%%% image ('Clean_cdataWB') to black. For avoiding searching the
     %%%%% subject mouse location in them.
%      if exist('InteractionZones')
%      for i=1:length(InteractionZones)
%         InteractionPixels=[];
%         InteractionPixels=InteractionZones{1,i}; 
%         for j=1:size(InteractionPixels,1)
%            Clean_cdataWB_ThresholdValue(InteractionPixels(j,1),InteractionPixels(j,2))=0; 
%            Clean_cdataWB_ThresholdValue(InteractionPixels(j,1),InteractionPixels(j,2))=0; 
%         end 
%      end
%      end
     
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
           se = strel('disk',1);
           InteractionAreaOnFrame=imdilate(InteractionAreaOnFrame,se);
           InteractionBoundariesPixels=bwboundaries(InteractionAreaOnFrame);
           if ~isempty(InteractionZones{1,i})
              AllInteractionBoundariesPixels{1,i}=InteractionBoundariesPixels{1,1};
           end
        end 
        firstFrame=cdataRGB; %%%%% This parameter is saved for returning the first image of the analysis for presentation requirments 
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
  
    
    

       
    %%%%% Presenting the data on the GUI - not for the fast one. 
    
%     imshow(cdataRGB,'Parent',HandlesForGUIControls.axes1);
%     set(HandlesForGUIControls.axes1,'Box','off','Visible','off') 
%     axes(HandlesForGUIControls.axes1);
%     hold on;  
    
    
    %%%%%%% ploting the mouse 
    if isempty(MouseBoundary_Threshold)  %%%%% activated when the algorithm did not find the mouse
        %MouseLoc=[MouseLoc; NaN,NaN];  
        %Have The Algorhtyhm assume the animal was in the same position as
        %the previous frame (this will help on frames where the animal
        %climbes and gets too small to be recognized by the image. 
        MouseLoc = [MouseLoc; MouseLoc(end,1),MouseLoc(end,2)];
        MissedFrame = MissedFrame+1;
        %plot(MouseLoc(1,end),MouseLoc(end,1),'rX'); %No plotting for the
        %fast one
    else
        %plot(mean(MouseBoundary_Threshold(:,2)),mean(MouseBoundary_Threshold(:,1)),'wX');
        %%No ploting for the fast one
    end
    
    hold off;
     
    TempNameStartPoint=strfind(Movie_fn, '\');
    set(HandlesForGUIControls.StatusBar,'string',['   Analyzed frame ' num2str(k) '    Final frame ' num2str(EndingFrame)]);    
      % set(HandlesForGUIControls.StatusBar,'string',[filenameBehavioral(TempNameStartPoint(end)+1:end) '   Analyzed frame ' num2str(k) '    Final frame ' num2str(EndingFrameForAnalysis)]);    
    
    if StopAnalysis
       LastFrame=k;
       break;
    end
  end
  
  clear Film
  LastFrame=k;
  
end
  
