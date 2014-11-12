function varargout = ValidateSkeleton(varargin)
% VALIDATESKELETON MATLAB code for ValidateSkeleton.fig
%      VALIDATESKELETON, by itself, creates a new VALIDATESKELETON or raises the existing
%      singleton*.
%
%      H = VALIDATESKELETON returns the handle to a new VALIDATESKELETON or the handle to
%      the existing singleton*.
%
%      VALIDATESKELETON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VALIDATESKELETON.M with the given input arguments.
%
%      VALIDATESKELETON('Property','Value',...) creates a new VALIDATESKELETON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ValidateSkeleton_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ValidateSkeleton_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ValidateSkeleton

% Last Modified by GUIDE v2.5 12-Nov-2014 13:53:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ValidateSkeleton_OpeningFcn, ...
                   'gui_OutputFcn',  @ValidateSkeleton_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ValidateSkeleton is made visible.
function ValidateSkeleton_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Skeleton (see VARARGIN)

% Choose default command line output for Skeleton
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthAppData')
    % should be the canonical way of calling the program
    
    app = varargin{1};
    setappdata(0, 'app', app);
    
else
    error('Deprecated way of calling ValidateSkeleton');
end

app.currentStep = 'skeleton';

frameIndex  = app.currentFrameIndex;
nFrames     = length(app.imageList);

% setup widgets
set(handles.currentFrameSlider, 'Min', 1);
set(handles.currentFrameSlider, 'Max', nFrames);
set(handles.currentFrameSlider, 'Value', frameIndex);
sliderStep = min(max([1 5] ./ (nFrames - 1), 0.001), 1);
set(handles.currentFrameSlider, 'SliderStep', sliderStep); 

% Compute skeletons that should be validated by the user
computeAllSkeletons(handles);

dirInitial  = app.firstPointLocation;

% update display
displayCurrentSkeleton(handles);

string = sprintf('Current Frame: %d / %d', frameIndex, nFrames);
set(handles.currentFrameLabel, 'String', string);

direction = 'boucle';
switch direction
    case 'boucle'
        set(handles.filterDirectionPopup, 'Value', 1);
    case 'droit'
        set(handles.filterDirectionPopup, 'Value', 2);
    case 'droit2'
        set(handles.filterDirectionPopup, 'Value', 3);
    case 'penche'
        set(handles.filterDirectionPopup, 'Value', 4);
    case 'penche2'
        set(handles.filterDirectionPopup, 'Value', 5);
    case 'dep'
        set(handles.filterDirectionPopup, 'Value', 6);
    case 'rien'
        set(handles.filterDirectionPopup, 'Value', 7);
end


switch dirInitial
    case 'bottom'
        set(handles.firstSkeletonPointPopup, 'Value', 1);
    case 'left'
        set(handles.firstSkeletonPointPopup, 'Value', 2);
    case 'right'
        set(handles.firstSkeletonPointPopup, 'Value', 3);
    case 'top'
        set(handles.firstSkeletonPointPopup, 'Value', 4);
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Skeleton wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ValidateSkeleton_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function mainFrameMenuItem_Callback(hObject, eventdata, handles)%#ok % To save the 
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
HypoGrowthMenu(app);


% --- Executes on slider movement.
function currentFrameSlider_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to currentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') retkurns position osf slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% disable slider to avoid multiple calls
set(handles.currentFrameSlider, 'Enable', 'Off');

app = getappdata(0, 'app');

% update frame index value
frameIndex = get(handles.currentFrameSlider, 'Value');
frameIndex = max(ceil(frameIndex), 1);

app.currentFrameIndex = frameIndex;

% update display
displayCurrentSkeleton(handles);

% update display of current frame index
nFrames = length(app.imageList);
string = sprintf('Current Frame: %d / %d', frameIndex, nFrames);
set(handles.currentFrameLabel, 'String', string);

% re-enable slider
set(handles.currentFrameSlider, 'Enable', 'On');


% --- Executes during object creation, after setting all properties.
function currentFrameSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to currentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on selection change in filterDirectionPopup.
function filterDirectionPopup_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to filterDirectionPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filterDirectionPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filterDirectionPopup


% --- Executes during object creation, after setting all properties.
function filterDirectionPopup_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to filterDirectionPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in firstSkeletonPointPopup.
function firstSkeletonPointPopup_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to firstSkeletonPointPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns firstSkeletonPointPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from firstSkeletonPointPopup


% --- Executes during object creation, after setting all properties.
function firstSkeletonPointPopup_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to firstSkeletonPointPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateSkeletonButton.
function updateSkeletonButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to updateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the skeleton with the new settings in popupmenu
set(handles.updateSkeletonButton, 'Enable', 'Off')
set(handles.updateSkeletonButton, 'String', 'Wait please...')
pause(0.01);

app = getappdata(0, 'app');

% parse popup containing info for starting skeleton
val2 = get(handles.firstSkeletonPointPopup, 'Value');
setappdata(0, 'val2', val2);
dirInitial = get(handles.firstSkeletonPointPopup, 'String');
dirInitial  = dirInitial{val2};

app.firstPointLocation = dirInitial;

% close the window and open again with the new settings
% TODO: could simply update the widgets...
delete(gcf);

ValidateSkeleton(app);

function displayCurrentSkeleton(handles)

app = getappdata(0, 'app');

frameIndex = app.currentFrameIndex;

% compute current segmented image
seuil = app.thresholdValues(frameIndex);
segmentedImage = app.imageList{frameIndex} > seuil;

% display current frame (image, contour, skeleton)
axes(handles.currentFrameAxes);
imshow(segmentedImage);
hold on;
drawContour(app.contourList{frameIndex}, 'r');
drawSkeleton(app.skeletonList{frameIndex}, 'b');
drawMarker(app.skeletonList{frameIndex}(1,:), 'bo');


function computeAllSkeletons(handles)
% compute skeletons from contours, and update widgets

% get current application data
app     = getappdata(0, 'app');
smooth  = app.contourSmoothingSize;
CT2     = app.contourList;

% To take the first values
val = get(handles.filterDirectionPopup, 'Value'); 
directionList = get(handles.filterDirectionPopup, 'String');
direction = directionList{val};

% To take the second value
val2 = get(handles.firstSkeletonPointPopup, 'Value');
stringList = get(handles.firstSkeletonPointPopup, 'String');
dirInitial = stringList{val2};

dir = direction;
dirbegin = dirInitial;

% number of images
nImages = length(CT2);

% allocate memory for results
CT      = cell(nImages, 1);
SK      = cell(nImages, 1);
shift   = cell(nImages, 1);
rad     = cell(nImages, 1);
CTVerif = cell(nImages, 1);
SKVerif = cell(nImages, 1);

disp('Skeletonization');
hDialog = msgbox(...
    {'Computing skeletons from contours,', 'please wait...'}, ...
    'Skeletonization');

parfor_progress(nImages);
for i = 1:nImages
    % Smooth current contour
    contour = CT2{i};
    if smooth ~= 0
        contour = smoothContour(contour, smooth);
    end
    
    % scale contour in user unit
    contour = contour * app.pixelSize / 1000;
    
    % Skeleton of current contour

%     CTVerif{i} = contour;
%     % to mimic old behaviour of skel55
%     contourf = CTfilter(contour, 200, dir); 
%     [SQ, R, order] = voronoiSkeleton(contourf);
%     [SKVerif{i}, rad{i}] = skeletonLargestPath(SQ, order, R);
    
    % Compute skeleton, without changing origin and y direction
    [SKVerif{i}, rad{i}] = skel55b(contour, dir, dirbegin);
    CTVerif{i} = contour;

    % apply translation and symmetry separately
    % coordinates at bottom left
    shift{i} = SKVerif{i}(1,:);
    % For new contour, align at bottom left
    CT{i}(:,1) = contour(:,1) - SKVerif{i}(1,1);
    CT{i}(:,2) = -(contour(:,2) - SKVerif{i}(1,2));
    % for new Skeleton, align at bottom left, and reverse y axis
    SK{i}(:,1) = SKVerif{i}(:,1) - SKVerif{i}(1,1);
    SK{i}(:,2) = -(SKVerif{i}(:,2) - SKVerif{i}(1,2));

    % keep skeleton in pixel units
    SKVerif{i} = SKVerif{i} * 1000 / app.pixelSize;
    
%    % old version   
%     CTVerif{i} = contour;
%     [SKVerif{i}, rad{i}] = skel55b(contour, dir, dirbegin);
%     CT{i} = CTVerif{i} * app.pixelSize;

    % Version 0
%     [SK{i}, CT{i}, shift{i}, rad{i}, SKVerif{i}, CTVerif{i}] = skel55(contour, dir, dirbegin);

    parfor_progress;
end

parfor_progress(0);
if ishandle(hDialog)
    close(hDialog);
end

% store new values in app data object
app.skeletonList = SKVerif;
app.radiusList = rad;

app.scaledContourList = CT;
app.scaledSkeletonList = SK;
app.originPosition = shift;

setappdata(0, 'app', app); 


% --- Executes on button press in saveSkeletonDataButton.
function saveSkeletonDataButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to saveSkeletonDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.saveSkeletonDataButton, 'Enable', 'Off');
set(handles.saveSkeletonDataButton, 'String', 'Wait please...');
pause(0.01);

app = getappdata(0, 'app'); %#ok<NASGU>

% To open the directory who the user want to save the data
[fileName, pathName] = uiputfile('*.mat', 'Save App Data', 'appData.mat'); 

if pathName == 0
    warning('Select a file please');
    return;
end

% save app data as .mat file
name = fullfile(pathName, fileName);
save(name, 'app');

set(handles.saveSkeletonDataButton, 'Enable', 'On');
set(handles.saveSkeletonDataButton, 'String', 'Save Skeleton Data');


% --- Executes on button press in BackToContourButton.
function BackToContourButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to BackToContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete (gcf);
ValidateContour(app);

% --- Executes on button press in validateSkeletonButton.
function validateSkeletonButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to validateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
StartElongation(app);
