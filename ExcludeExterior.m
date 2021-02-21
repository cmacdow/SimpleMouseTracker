function [AllExcludedAreas] = ExcludeExterior(HandlesForGUIControls,ExcludedAreasList)
%EXCLUDEAREA Summary of this function goes here
%   Detailed explanation goes here
scale =2;
CurrentFileAnalyzed =1;
% AreaToExclude = impoly(HandlesForGUIControls.axes1);
AreaToExclude = imrect(HandlesForGUIControls.axes1,[10 10 450/scale 280/scale]);
wait(AreaToExclude); 
PixelsForRemoval = createMask(AreaToExclude);
[RowForRemoval,ColForRemoval] = find(PixelsForRemoval==0); %0 will remove the exterior locations
try
   Temp=size(ExcludedAreasList(CurrentFileAnalyzed,:),2)+1;
catch
   Temp=1; 
end
ExcludedAreasList{CurrentFileAnalyzed,Temp}=[RowForRemoval,ColForRemoval];
AllExcludedAreas=ExcludedAreasList;

end
