function [LastOpenDirectory]=InspectMovie(LastOpenDirectory)
%INSPECTMOVIE Summary of this function goes here
%   Detailed explanation goes here
  

if isempty(LastOpenDirectory)
   [FileToInspect,PathToFileForInspection]=uigetfile('*.avi','Please select an avi file or multiple avi files','MultiSelect', 'off');
else
   [FileToInspect,PathToFileForInspection]=uigetfile('*.avi','Please select an avi file or multiple avi files','MultiSelect', 'off',LastOpenDirectory); 
end
Movie_fn=[PathToFileForInspection,FileToInspect]; 
LastOpenDirectory=PathToFileForInspection;
implay(Movie_fn);

end

