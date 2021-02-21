function [InteractionZones] = InteractionZoneDefine(HandlesForGUIControls,InteractionZones,IntZoneNum);
%COMPARTMENT_STIMULUS_DEFINITION Summary of this function goes here
%   Detailed explanation goes here
scale = 2;
CurrentFileAnalyzed = 1;
% InteractionArea = imellipse(HandlesForGUIControls.axes1);
InteractionArea = imellipse(HandlesForGUIControls.axes1,[200 200 130/scale 130/scale]);
wait(InteractionArea); 
InteractionPixels = createMask(InteractionArea);
[InteractRow,InteractCol] = find(InteractionPixels==1);
InteractionZones{CurrentFileAnalyzed,IntZoneNum}=[InteractRow,InteractCol];
end

