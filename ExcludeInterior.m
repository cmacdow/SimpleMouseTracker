function [AllExcludedAreas] = ExcludeInterior(HandlesForGUIControls,ExcludedAreasList)
%EXCLUDEAREA Summary of this function goes here
%   Detailed explanation goes here

CurrentFileAnalyzed =1;
AreaToExclude = impoly(HandlesForGUIControls.axes1);
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
