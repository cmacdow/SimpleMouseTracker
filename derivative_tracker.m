function imgD= ImageDerivative(

%derivative tracker

film = VideoReader('Z:\Users\Kennedy\thesis\repetitive grooming\10-19-20\301.mp4');

StartTime = 1000;
EndTime = 2000;
figure;
for k = StartTime:EndTime-1
   data = sum(imbinarize(read(film,k)-read(film,k+1)),3);
   %open to get rid of spot noise
   cleandata = bwareaopen(data, 120); 
   %close to seal mouse
   se = strel('disk',120);
   cleandata = imclose(cleandata,se);
   
   %get the boundaries
   BoundariesWB = bwboundaries(cleandata);
   hold on

   for i=1:size(BoundariesWB,1) 
     BoundaryToPlot=BoundariesWB{i,1}; 
     plot(BoundaryToPlot(:,2),BoundaryToPlot(:,1),'-g','LineWidth',2) 
   end
end
