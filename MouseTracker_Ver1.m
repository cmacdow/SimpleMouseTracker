function varargout = MouseTracker_Ver1(varargin)
% MOUSETRACKER_VER1 MATLAB code for MouseTracker_Ver1.fig
%      MOUSETRACKER_VER1, by itself, creates a new MOUSETRACKER_VER1 or raises the existing
%      singleton*.
%
%      H = MOUSETRACKER_VER1 returns the handle to a new MOUSETRACKER_VER1 or the handle to
%      the existing singleton*.
%
%      MOUSETRACKER_VER1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOUSETRACKER_VER1.M with the given input arguments.
%
%      MOUSETRACKER_VER1('Property','Value',...) creates a new MOUSETRACKER_VER1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MouseTracker_Ver1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MouseTracker_Ver1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MouseTracker_Ver1

% Last Modified by GUIDE v2.5 16-Dec-2020 07:17:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MouseTracker_Ver1_OpeningFcn, ...
                   'gui_OutputFcn',  @MouseTracker_Ver1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
%     [varargout{1:nargout}] = MouseTracker_Ver1_OpeningFcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
%     MouseTracker_Ver1_OpeningFcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MouseTracker_Ver1 is made visible.
function MouseTracker_Ver1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MouseTracker_Ver1 (see VARARGIN)

% Choose default command line output for MouseTracker_Ver1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MouseTracker_Ver1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MouseTracker_Ver1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%  parameters for analysis session  %%%%%%%%%%%%%%%%%%%%%%%%
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis
global SaveData;
global SaveMovie;
global dsFactor;
global MouseNum;
global ExpType;

HandlesForGUIControls=handles;
AllExcludedAreas={};
CompartmentsPositions={};
InteractionZones={};
StartingFrame=1;
EndingFrame=[];
ThresholdValue=0.5;
AnalysisDuration = 600;
SaveData = [];
SaveMovie = [];
dsFactor = 1;
MouseNum = [];
ExpType = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%   Session analysis panel   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% OBJECT FUNCTIONS Start %%%%%%%%%%%%%%%%
% --- Executes on button press in LoadMovie.
function LoadMovie_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;

 try
    [Movie_fn,CurrentFrameData,LastOpenDirectory] = LoadMovie(HandlesForGUIControls,LastOpenDirectory);
    [~, MovieName] = fileparts(Movie_fn);
    StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
    ThresholdValue = str2num(get(HandlesForGUIControls.StopFrameEdit,'String')); 
    CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
        HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);
    Film = VideoReader(Movie_fn);
    MaxFrameNum=floor(Film.Duration*Film.FrameRate);
    set(HandlesForGUIControls.StopFrameEdit,'string',num2str(MaxFrameNum));
    set(HandlesForGUIControls.StatusBar,'string',Movie_fn); 
    set(HandlesForGUIControls.MovieNameBar,'string',MovieName); 
    EndingFrame = MaxFrameNum;
    clear Film;
catch
    errordlg('No movie was chosen or the movie is damaged')   
end

% --- Executes on button press in InspectMovie.
function InspectMovie_Callback(hObject, eventdata, handles)
% hObject    handle to InspectMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LastOpenDirectory;

[LastOpenDirectory]=InspectMovie(LastOpenDirectory);

% --- Executes on button press in ExcludeBoundary.
function ExcludeBoundary_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeBoundary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;


StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
AllExcludedAreas=ExcludeExterior(HandlesForGUIControls,AllExcludedAreas);   
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);



% --- Executes on button press in ExcludeObj1.
function ExcludeObj1_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeObj1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;


StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
AllExcludedAreas=ExcludeObj(HandlesForGUIControls,AllExcludedAreas);   
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);


% --- Executes on button press in ExcludeObj2.
function ExcludeObj2_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeObj2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;

StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
AllExcludedAreas=ExcludeObj(HandlesForGUIControls,AllExcludedAreas);   
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);


% --- Executes on button press in Compartment1.
function Compartment1_Callback(hObject, eventdata, handles)
% hObject    handle to Compartment1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;

StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
CompartmentNum = 1;
CompartmentsPositions = CompartmentDefine(HandlesForGUIControls,CompartmentsPositions,CompartmentNum);
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);

% --- Executes on button press in Compartment2.
function Compartment2_Callback(hObject, eventdata, handles)
% hObject    handle to Compartment2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;


StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
CompartmentNum = 2;
CompartmentsPositions = CompartmentDefine(HandlesForGUIControls,CompartmentsPositions,CompartmentNum);
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);

% --- Executes on button press in Compartment3.
function Compartment3_Callback(hObject, eventdata, handles)
% hObject    handle to Compartment3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;


StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
CompartmentNum = 3;
CompartmentsPositions = CompartmentDefine(HandlesForGUIControls,CompartmentsPositions,CompartmentNum);
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);

% --- Executes on button press in IntZone1.
function IntZone1_Callback(hObject, eventdata, handles)
% hObject    handle to IntZone1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;


StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
IntZoneNum = 1; %Initial Social Approach Animal
InteractionZones = InteractionZoneDefine(HandlesForGUIControls,InteractionZones,IntZoneNum);
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);

% --- Executes on button press in IntZone2.
function IntZone2_Callback(hObject, eventdata, handles)
% hObject    handle to IntZone2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global CurrentFrameData;
global StartingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
StartingFrame = str2num(get(HandlesForGUIControls.StartFrameEdit,'String'));
IntZoneNum = 2; %This is for the novel object location in SA and stranger animal in SN. 
InteractionZones = InteractionZoneDefine(HandlesForGUIControls,InteractionZones,IntZoneNum);
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);

% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis
global SaveData;
global SaveMovie;
global MouseNum;
global ExpType;

HandlesForGUIControls=handles;
AllExcludedAreas={};
CompartmentsPositions={};
InteractionZones={};
StartingFrame=1;
EndingFrame=[];
ThresholdValue=[];
AnalysisDuration = [];
SaveData = [];
SaveMovie = [];
MouseNum = [];
ExpType = [];
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);  
set(HandlesForGUIControls.StartFrameEdit,'String','1');
set(HandlesForGUIControls.StopFrameEdit,'String','');
set(HandlesForGUIControls.DurationAnalyze,'String','600');
set(HandlesForGUIControls.thresholdvalue,'String','0.5');
set(HandlesForGUIControls.MousePixelSize,'String','60');
set(HandlesForGUIControls.StatusBar,'String','Analysis Reset Complete');
set(HandlesForGUIControls.MouseNum,'String','');
set(HandlesForGUIControls.ExpType,'String','');




% --- Executes on selection change in AlgMenu.
function AlgMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AlgMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AlgMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AlgMenu


% --- Executes on button press in StartAnalysis.
function StartAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to StartAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis
global SaveData;
global SaveMovie;
global dsFactor;
global MouseNum;
global ExpType;

StopAnalysis=0;
contents = get(HandlesForGUIControls.AlgMenu,'string');
SelectedAlgorithm=contents{get(HandlesForGUIControls.AlgMenu,'Value')};

switch SelectedAlgorithm
   case 'MiceMovieAnalyzerCJM_2018'
      [MissedFrame,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,...
          LastFrame]=MiceMovieAnalyzerCJM_2018(Movie_fn,...
          HandlesForGUIControls,StartingFrame,EndingFrame,...
          AllExcludedAreas,CompartmentsPositions,InteractionZones,...
          SaveMovie,ThresholdValue,MousePixelSize,dsFactor);
      set(HandlesForGUIControls.StatusBar,'string','Finished analyzing');
      if SaveData==1
         Save_fn=[Movie_fn '_video_data_results', '.mat'];
         save(Save_fn,'Movie_fn','LastFrame','firstFrame',...
             'AllExcludedAreas','CompartmentsPositions','InteractionZones',...
         'MouseLoc','InteractionTimes','CompartmentTimes','ThresholdValue',...
         'StartingFrame','EndingFrame','MissedFrame',...
         'DurationAnalyze','AnalysisDuration','dsFactor','MouseNum','ExpType');
         set(HandlesForGUIControls.StatusBar,'string','Analysis parameters and data were saved'); 
      else
          warning('Save data was not selected. No data was saved for %s',Movie_fn)
      end
   case 'MiceMovieAnalyzerCJM_2018_fast'
      [MissedFrame,MouseLoc,InteractionTimes,CompartmentTimes,firstFrame,...
          LastFrame]=MiceMovieAnalyzerCJM_2018_fast(Movie_fn,...
          HandlesForGUIControls,StartingFrame,EndingFrame,...
          AllExcludedAreas,CompartmentsPositions,InteractionZones,...
          SaveMovie,ThresholdValue,MousePixelSize,dsFactor);
      set(HandlesForGUIControls.StatusBar,'string','Finished analyzing');
      if SaveData==1
         Save_fn=[Movie_fn '_video_data_results', '.mat'];
         save(Save_fn,'Movie_fn','LastFrame','firstFrame',...
             'AllExcludedAreas','CompartmentsPositions','InteractionZones',...
         'MouseLoc','InteractionTimes','CompartmentTimes','ThresholdValue',...
         'StartingFrame','EndingFrame','MissedFrame',...
         'DurationAnalyze','AnalysisDuration','dsFactor','MouseNum','ExpType');
         set(HandlesForGUIControls.StatusBar,'string','Analysis parameters and data were saved'); 
      else
          warning('Save data was not selected. No data was saved for %s',Movie_fn)
      end   
   otherwise
      errordlg('Please choose an algorithm for analysis');    
      return;
end
if StopAnalysis
  return;
end



% --- Executes on button press in StopAnalysis.
function StopAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to StopAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis

StopAnalysis = 1; 

% --- Executes on button press in SaveAnalysis.
function SaveAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%% OBJECT FUNCTIONS END %%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% EDIT VALUES START %%%%%%%%%%%%%%%


function StartFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StartFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of StartFrameEdit as a double
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;

Film = VideoReader(Movie_fn);
nFrames = floor(Film.Duration*Film.FrameRate);
CurrentFileAnalyzed = 1;
clear Film;
if str2num(get(hObject,'String'))<=nFrames
   StartingFrame(CurrentFileAnalyzed)=str2num(get(hObject,'String')); 
   CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
        HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);
else
    set(hObject,'String',num2str(nFrames))
    warndlg('Outside frame range...\n',...
        ['The maximal number of frames in the movie is ' num2str(nFrames)],...
        'defaulted to final frame index');
end

function DurationAnalyze_Callback(hObject, eventdata, handles)
% hObject    handle to DurationAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DurationAnalyze as text
%        str2double(get(hObject,'String')) returns contents of DurationAnalyze as a double
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;

Film = VideoReader(Movie_fn);
nFrames = floor(Film.Duration*Film.FrameRate);
CurrentFileAnalyzed = 1;

AnalysisDuration = str2num(get(hObject,'String'));
EndingFrame = (AnalysisDuration*Film.FrameRate)+StartingFrame;

if EndingFrame<=nFrames
    set(HandlesForGUIControls.StopFrameEdit,'String',num2str(EndingFrame));
else
    set(HandlesForGUIControls.StopFrameEdit,'String',num2str(nFrames))
    warndlg('Outside frame range...\n',...
        ['The maximal number of frames in the movie is ' num2str(nFrames)],...
        'Please set analysis duration for a shorter length');
    AnalysisDuration = floor((EndingFrame - StartingFrame)/Film.FrameRate); 
    set(HandlesForGUIControls.DurationAnalyze,'String',num2str(AnalysisDuration));
end
clear Film;

function StopFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StopFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StopFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of StopFrameEdit as a double

global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;

Film = VideoReader(Movie_fn);
nFrames = floor(Film.Duration*Film.FrameRate);
CurrentFileAnalyzed = 1;
if str2num(get(hObject,'String'))<=nFrames
    EndingFrame(CurrentFileAnalyzed)=str2num(get(hObject,'String')); 
    AnalysisDuration = floor((EndingFrame - StartingFrame)/Film.FrameRate); 
    set(HandlesForGUIControls.DurationAnalyze,'String',num2str(AnalysisDuration));
else
    set(hObject,'String',num2str(nFrames))
    warndlg('Outside frame range...\n',...
        ['The maximal number of frames in the movie is ' num2str(nFrames)],...
        'Defaulted to final frame number');
    AnalysisDuration = floor((EndingFrame - StartingFrame)/Film.FrameRate); 
    set(HandlesForGUIControls.DurationAnalyze,'String',num2str(AnalysisDuration));
end
clear Film;


function thresholdvalue_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdvalue as text
%        str2double(get(hObject,'String')) returns contents of thresholdvalue as a double
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;

CurrentFileAnalyzed = 1;
ThresholdValue = str2double(get(hObject,'String'));
StartingFrame(CurrentFileAnalyzed)=str2num(get(HandlesForGUIControls.StartFrameEdit,'String')); 
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);
MousePixelSize = str2double(get(HandlesForGUIControls.MousePixelSize,'String'));

Film = VideoReader(Movie_fn);
%%%%% open the image, convert it to black and white and clean it from noise      
cdataRGB = read(Film,StartingFrame);
cdataBW=im2bw(cdataRGB,ThresholdValue);
cdataWB=zeros(size(cdataBW,1),size(cdataBW,2));
cdataWB(find(cdataBW==0))=1;
Clean_cdataWB = bwareaopen(cdataWB, MousePixelSize);

%%%%% exclude pixels that were excluded from the image by the user
if ~isempty(AllExcludedAreas)
  for i=1:length(AllExcludedAreas(CurrentFileAnalyzed,:))
     AreaToExclude=[];
     AreaToExclude=AllExcludedAreas{CurrentFileAnalyzed,i}; 
     for j=1:size(AreaToExclude,1)
        Clean_cdataWB(AreaToExclude(j,1),AreaToExclude(j,2))=0;
     end 
  end
end

%%%%% look for boundaries of the animal
BoundariesWB = bwboundaries(Clean_cdataWB);
axes(HandlesForGUIControls.axes1);
hold on;

for i=1:size(BoundariesWB,1) 
  BoundaryToPlot=BoundariesWB{i,1}; 
  plot(BoundaryToPlot(:,2),BoundaryToPlot(:,1),'-g','LineWidth',2) 
end

function MousePixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to MousePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MousePixelSize as text
%        str2double(get(hObject,'String')) returns contents of MousePixelSize as a double
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;

CurrentFileAnalyzed = 1;
ThresholdValue = str2double(get(HandlesForGUIControls.thresholdvalue,'String'));
StartingFrame(CurrentFileAnalyzed)=str2num(get(HandlesForGUIControls.StartFrameEdit,'String')); 
CurrentFrameData = UpdateCurrentFrame(Movie_fn,StartingFrame,...
    HandlesForGUIControls,AllExcludedAreas,CompartmentsPositions,InteractionZones);
MousePixelSize = str2double(get(hObject,'String'));

Film = VideoReader(Movie_fn);
%%%%% open the image, convert it to black and white and clean it from noise      
cdataRGB = read(Film,StartingFrame);
cdataBW=im2bw(cdataRGB,ThresholdValue(CurrentFileAnalyzed));
cdataWB=zeros(size(cdataBW,1),size(cdataBW,2));
cdataWB(find(cdataBW==0))=1;
Clean_cdataWB = bwareaopen(cdataWB, MousePixelSize);

%%%%% exclude pixels that were excluded from the image by the user
if ~isempty(AllExcludedAreas)
  for i=1:length(AllExcludedAreas(CurrentFileAnalyzed,:))
     AreaToExclude=[];
     AreaToExclude=AllExcludedAreas{CurrentFileAnalyzed,i}; 
     for j=1:size(AreaToExclude,1)
        Clean_cdataWB(AreaToExclude(j,1),AreaToExclude(j,2))=0;
     end 
  end
end

%%%%% look for boundaries of the animal
BoundariesWB = bwboundaries(Clean_cdataWB);
axes(HandlesForGUIControls.axes1);
hold on;

for i=1:size(BoundariesWB,1) 
  BoundaryToPlot=BoundariesWB{i,1}; 
  plot(BoundaryToPlot(:,2),BoundaryToPlot(:,1),'-g','LineWidth',2) 
end


function StatusBar_Callback(hObject, eventdata, handles)
% hObject    handle to StatusBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StatusBar as text
%        str2double(get(hObject,'String')) returns contents of StatusBar as a double

% --- Executes on button press in savedatacheckbox.
function savedatacheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to savedatacheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of savedatacheckbox

global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis;
global SaveData;
global SaveMovie;
value = get(hObject, 'Value');
if value == 1;
    SaveData = 1; 
    fprintf('\nSaving data...\n')
else
    fprintf('\nWill not save data...\n')
end

    

% --- Executes on button press in saveanalysismovie.
function saveanalysismovie_Callback(hObject, eventdata, handles)
% hObject    handle to saveanalysismovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveanalysismovie
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis;
global SaveData;
global SaveMovie;

value = get(hObject, 'Value');
if value == 1;
    SaveMovie = 1; 
    fprintf('\nSaving movie...\n')
else
    fprintf('\nWill not save movie...\n')
end


% --- Executes on button press in SaveConfig.
function SaveConfig_Callback(hObject, eventdata, handles)
% hObject    handle to SaveConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis;
global SaveData;
global SaveMovie;
global dsFactor;
global MouseNum;
global ExpType;

set(HandlesForGUIControls.StatusBar,'string','Analysis Parameters Saved For Batch Processing');
%remove the extension on the movie name
[~,Save_fn] = fileparts(Movie_fn);
Save_fn=[Save_fn '_' ExpType '_batchConfig', '.mat'];
save(Save_fn,'Movie_fn','StartingFrame','EndingFrame',...
 'AllExcludedAreas','CompartmentsPositions','InteractionZones',...
 'ThresholdValue','AnalysisDuration', 'MousePixelSize','dsFactor','MouseNum','ExpType');



function MovieNameBar_Callback(hObject, eventdata, handles)
% hObject    handle to MovieNameBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MovieNameBar as text
%        str2double(get(hObject,'String')) returns contents of MovieNameBar as a double


function dsFactor_Callback(hObject, eventdata, handles)
% hObject    handle to dsFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dsFactor as text
%        str2double(get(hObject,'String')) returns contents of dsFactor as a double
global HandlesForGUIControls
global Movie_fn;
global LastOpenDirectory;
global CurrentFrameData;
global StartingFrame;
global EndingFrame;
global DurationAnalyze;
global AllExcludedAreas;
global CompartmentsPositions;
global InteractionZones;
global ThresholdValue;
global AnalysisDuration;
global MousePixelSize;
global StopAnalysis;
global SaveData;
global SaveMovie;
global dsFactor; 

dsFactor = str2double(get(hObject, 'String'));

function MouseNum_Callback(hObject, eventdata, handles)
% hObject    handle to MouseNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MouseNum as text
%        str2double(get(hObject,'String')) returns contents of MouseNum as a double
global MouseNum

MouseNum = str2double(get(hObject,'String'));

function ExpType_Callback(hObject, eventdata, handles)
% hObject    handle to ExpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExpType as text
%        str2double(get(hObject,'String')) returns contents of ExpType as a double

global ExpType

ExpType = get(hObject,'String');

%%%%%%%%%%%%%%%% EDIT VALUES END %%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%OBJECT CREATION START%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function StatusBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StatusBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function AlgMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AlgMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function StartFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function StopFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StopFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function thresholdvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function DurationAnalyze_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DurationAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function MousePixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MousePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function MovieNameBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieNameBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function dsFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function MouseNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MouseNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function ExpType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%OBJECT CREATION END%%%%%%%%%%%%%%%%%%%%%%%%%%%
