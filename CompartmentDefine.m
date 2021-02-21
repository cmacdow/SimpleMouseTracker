function [CompartmentsPositions] = CompartmentDefine(HandlesForGUIControls,CompartmentsPositions,CompartmentNum)
%COMPARTMENT_STIMULUS_DEFINITION Summary of this function goes here
%   Detailed explanation goes here
scale = 2;
CurrentFileAnalyzed = 1;
% CompartmentArea = impoly(HandlesForGUIControls.axes1);
CompartmentArea = imrect(HandlesForGUIControls.axes1, [50 50 150/scale 280/scale]);
wait(CompartmentArea); 
CompartmentPixels = createMask(CompartmentArea);
[CompartmentRow,CompartmentCol] = find(CompartmentPixels==1);
CompartmentsPositions{CurrentFileAnalyzed,CompartmentNum}=[CompartmentRow,CompartmentCol];
end

