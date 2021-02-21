function [AllExcludedAreas] = ExcludeObj(HandlesForGUIControls,ExcludedAreasList)
%EXCLUDEAREA Summary of this function goes here
%   Detailed explanation goes here
scale = 2;
CurrentFileAnalyzed =1;
% AreaToExclude = imellipse(HandlesForGUIControls.axes1);
AreaToExclude = imellipse(HandlesForGUIControls.axes1,[180 180 100/scale 80/scale]);
wait(AreaToExclude); 
PixelsForRemoval = createMask(AreaToExclude);
[RowForRemoval,ColForRemoval] = find(PixelsForRemoval==1); %0 will remove the exterior locations
try
   Temp=size(ExcludedAreasList(CurrentFileAnalyzed,:),2)+1;
catch
   Temp=1; 
end
ExcludedAreasList{CurrentFileAnalyzed,Temp}=[RowForRemoval,ColForRemoval];
AllExcludedAreas=ExcludedAreasList;

end
