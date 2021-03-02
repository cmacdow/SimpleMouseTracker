function [Movie_fn, CurrentFrameData, LastOpenDirectory] = LoadMovie(HandlesForGUIControls, LastOpenDirectory)
%LOADSESSIONFILE Summary of this function goes here
%   Detailed explanation goes here

  if isempty(LastOpenDirectory)
     [File,Path]=uigetfile('*.','Please select an movie file or multiple movie files','MultiSelect', 'on');
  else
     [File,Path]=uigetfile('*.','Please select an movie file or multiple movie files','MultiSelect', 'on',LastOpenDirectory); 
  end
  Movie_fn=[Path,File]; 
  LastOpenDirectory=Path;
  if ischar(File)
     Film = VideoReader([Path,File]);
     CurrentFrameData = readFrame(Film); 
  else
     Film = VideoReader([Path,File{1,1}]);
     CurrentFrameData = readFrame(Film); 
  end
%   set(gcf,'Position',[10 50 1905 1040] )
  imshow(CurrentFrameData,'Parent',HandlesForGUIControls.axes1);
  set(HandlesForGUIControls.axes1,'Box','off','Visible','off')
  clear Film;
  
  if ~ischar(File)
     warndlg('Sorry, this program does not currently support multiple file selection')
      %warndlg('Please notic you choosed multiple avi files')
     uiwait;
  end
end

