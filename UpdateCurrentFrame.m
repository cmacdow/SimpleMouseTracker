function [CurrentFrameData] = UpdateCurrentFrame(Movie_fn,StartingFrame,HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones)
%UPDATECURRENTFRAMEDATA Summary of this function goes here
%   Detailed explanation goes here

%%%%%  Load the frame from the original movie
Film = VideoReader(Movie_fn);
CurrentFrameData = read(Film,StartingFrame);
CurrentFileAnalyzed = 1; %You can go back and change this later to permit batching of files. 
%%%%% Mark areas in different colors
try
   for i=1:length(AllExcludedAreas(CurrentFileAnalyzed,:))
      AreaToExclude=[];
      AreaToExclude=AllExcludedAreas{CurrentFileAnalyzed,i}; 
      for j=1:size(AreaToExclude,1)
         CurrentFrameData(AreaToExclude(j,1),AreaToExclude(j,2),1)=255; %%%% Mark excluded areas is red
      end 
   end
catch
   %%% Do nothing 
end
try
   for i=1:length(CompartmentsPositions(CurrentFileAnalyzed,:))
      Compartment=[];
      Compartment=CompartmentsPositions{CurrentFileAnalyzed,i}; 
      for j=1:size(Compartment,1)
         CurrentFrameData(Compartment(j,1),Compartment(j,2),1)='c';  %%%% Mark compartments areas in cyan and slowly darken for each compartment
         
      end 
   end
catch
    %%% Do nothing
end

try
   for i=1:length(InteractionZones(CurrentFileAnalyzed,:))
      InteractionArea=[];
      InteractionArea=InteractionZones{CurrentFileAnalyzed,i}; 
     
      for j=1:size(InteractionArea,1)
         CurrentFrameData(InteractionArea(j,1),InteractionArea(j,2),3)='g';  %%%% Mark stimuli areas in yellow
     
      end 
   end
catch
    %%% Do nothing
end


%%%%% present the image and text on it%%%%
cla reset
imshow(CurrentFrameData,'Parent',HandlesForGUIControls.axes1);
set(HandlesForGUIControls.axes1,'Box','off','Visible','off')
axes(HandlesForGUIControls.axes1);

try
   for i=1:length(CompartmentsPositions(CurrentFileAnalyzed,:))
      Compartment=[];
      Compartment=CompartmentsPositions{CurrentFileAnalyzed,i}; 
      if ~isempty(Compartment)
         text(mean(Compartment(:,2)),mean(Compartment(:,1)),['Compartment ' num2str(i)],'FontSize',12)
      end
   end
catch
    %%% Do nothing
end

try
   for i=1:length(InteractionZones(CurrentFileAnalyzed,:))
      InteractionArea=[];
      InteractionArea=InteractionZones{CurrentFileAnalyzed,i}; 
      if ~isempty(InteractionArea)
         if i ==1
            text(mean(InteractionArea(:,2)),mean(InteractionArea(:,1)),['SA/Fam ' num2str(i)],'FontSize',12) 
         else
            text(mean(InteractionArea(:,2)),mean(InteractionArea(:,1)),['Empty/SN ' num2str(i)],'FontSize',12)
         end
      end
   end
catch
    %%% Do nothing
end



end

