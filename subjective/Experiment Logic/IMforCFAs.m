function varargout = IMforCFAs(varargin)
% IMFORCFAS MATLAB code for IMforCFAs.fig
%      IMFORCFAS, by itself, creates a new IMFORCFAS or raises the existing
%      singleton*.
%
%      H = IMFORCFAS returns the handle to a new IMFORCFAS or the handle to
%      the existing singleton*.
%
%      IMFORCFAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMFORCFAS.M with the given input arguments.
%
%      IMFORCFAS('Property','Value',...) creates a new IMFORCFAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IMforCFAs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IMforCFAs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IMforCFAs

% Last Modified by GUIDE v2.5 20-Nov-2012 17:28:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IMforCFAs_OpeningFcn, ...
                   'gui_OutputFcn',  @IMforCFAs_OutputFcn, ...
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


% --- Outputs from this function are returned to the command line.
function varargout = IMforCFAs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes just before IMforCFAs is made visible.
function IMforCFAs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IMforCFAs (see VARARGIN)


% Instead of using global, all of these variables could be stored in
% handles.
global pairs orders votes imagenames subjectname rawdata

% Choose default command line output for IMforCFAs
handles.output = hObject;
folders = {};

folders{end+1} = fullfile(L3Experimentrootpath,'Images','Buildings50');
folders{end+1} = fullfile(L3Experimentrootpath,'Images','Buildings100');
folders{end+1} = fullfile(L3Experimentrootpath,'Images','Conny');
folders{end+1} = fullfile(L3Experimentrootpath,'Images','Fruit');
% folders{end+1} = fullfile(L3Experimentrootpath,'Images','Moire');
folders{end+1} = fullfile(L3Experimentrootpath,'Images','People');
folders{end+1} = fullfile(L3Experimentrootpath,'Images','Text');
folders{end+1} = fullfile(L3Experimentrootpath,'Images','Tomato');
folders{end+1} = fullfile(L3Experimentrootpath,'Images','Uniform');



subjectname = inputdlg(['This experiment evaluates which images you prefer. ',sprintf('\n'),...
        'For each pair of images, please select the one you prefer.',sprintf('\n\n'),...
        'There are ',num2str(length(folders)),' sets of images in the experiment.',sprintf('\n'),...
        'You may take a break after each set.',sprintf('\n\n'),...
        'Either use the mouse to click on buttons or the following keyboard shortcuts:',sprintf('\n'),...
        '      <left arrow>:   select left image',sprintf('\n'),...
        '      <right arrow>:  select right image',sprintf('\n'),...
        '           Z:         submits the selection',sprintf('\n\n'),...
        'Please enter your name:'],'Welcome');
subjectname = subjectname{1};   % convert cell to string


orders = cell(size(folders));
for foldernum = 1:length(folders)
    orders{foldernum} = [11, 3, 2, 5, 1, 4, 9, 7, 8, 6, 10];
    %initial guess based on using GUI once
    
    % Numbers refer to the following methods: L3_5band, L3_Bayer, L3_CMY4,
    % L3_RGBx, L3_multi1, basic_5band, basic_Bayer, basic_CMY4, basic_RGBx,
    % basic_multi1, ideal       (for example 11 means ideal is best)
end


imagenames = [];
for foldernum = 1:length(folders)
    folder = folders{foldernum};
    im_Files = dir([folder,filesep,'*.png']);
    if length(orders{foldernum}) ~= length(im_Files)
        error('Order length does not match length of input images')
    end
    for filenum = 1:length(im_Files)
        imagenames{foldernum,filenum} = [folder,filesep,im_Files(filenum).name];
    end
end


[pairs, orders, votes] = setupexperiment(orders);

rawdata = struct;
rawdata.time = [];
rawdata.preference = [];
rawdata.pairs = [];

% Load first pair of images
scenenum = pairs(1,1);     imleft = pairs(1,2);   imright = pairs(1,3);

% Load image on left
clc
axes(handles.axes1);
img= imread( imagenames{scenenum,imleft} );
image(img);
axis off;

% Load image on right
clc
axes(handles.axes2);
img= imread( imagenames{scenenum,imright} );
image(img);
axis off;

% RGB information
% datacursormode on

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in leftradiobutton.
function leftradiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to leftradiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of leftradiobutton
if (get(handles.leftradiobutton,'Value'))
    set(handles.rightradiobutton,'Value', 0)
end

% --- Executes on button press in rightradiobutton.
function rightradiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to rightradiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rightradiobutton
if (get(handles.rightradiobutton,'Value'))
    set(handles.leftradiobutton,'Value', 0)
end



% --- Executes on button press in nextbutton.
function nextbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global pairs orders votes imagenames subjectname rawdata

rawdata.time(end+1,:) = clock;
rawdata.pairs(end+1,:) = pairs(1,:);    %record pair that was just shown

% User selection
L = get(handles.leftradiobutton,'Value');
R = get(handles.rightradiobutton,'Value');

if L > R
    preference = 1;
    set(handles.leftradiobutton,'Value', 0)  % turn off selection
elseif L < R
    preference = 2;
    set(handles.rightradiobutton,'Value', 0)  % turn off selection
else
    warning('Selection is required')
    return
end

clc     %clear screen (probably only gets rid of old warnings)
rawdata.preference(end+1) = preference;

currentscene = pairs(1,1);  % current scene that is being tested
[pairs, orders, votes] = submitvote(preference, pairs, orders, votes);

resultfilename = fullfile(L3Experimentrootpath,...
    'Results',[subjectname,'.mat']);  %place to save results
    
if ~isempty(pairs)  % pairs is empty when the experiment is finished

    nextscene = pairs(1,1);  % next scene to be tested

    if currentscene ~= nextscene  % changing scenes
        totalscenes = length(orders);
         uiwait(msgbox(['You completed scene ',num2str(currentscene),' of ',...
                num2str(totalscenes),sprintf('.\n\n'),...
                'You may now take a break.',sprintf('\n'),...
                'Press OK when ready to continue.'],'Scene Complete','modal'));
        
        if ~isempty(strfind(imagenames{nextscene,1}, 'Buildings100'))
            uiwait(msgbox(['The next set of images is similar but slightly ',...
                'different than the previous set.'],'Scene Complete','modal'));
        end        

        if ~isempty(strfind(imagenames{nextscene,1}, 'Uniform'))
            uiwait(msgbox(['For the next set of images, please choose the image that appears the most uniform.',sprintf('\n'),...
                'In other words, the image that most appears to have a constant color throughout the image.'],'Scene Complete','modal'));
        end
    end
    
    % Display the next pair of images
    scenenum = pairs(1,1);     imleft = pairs(1,2);   imright = pairs(1,3);

    axes(handles.axes1);
    img= imread( imagenames{scenenum,imleft} );
    image(img);
    axis off;

    axes(handles.axes2);
    img= imread( imagenames{scenenum,imright} );
    image(img);
    axis off;    

    % Save current state (in case experiment is stopped before completion.
    save(resultfilename,'orders','votes','imagenames','pairs','rawdata')
    
else
    % Following runs if the test is finished.
    save(resultfilename,'orders','votes','imagenames','rawdata')
    buttonname = questdlg('Finished.  Thanks for your participation.'...
        ,'Done','End Experiment','End Experiment');
    delete(gcf);    %Close figure
    
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buttonname = questdlg('Are you sure you want to close?  All data will be lost'...
    ,'Confirm Close','No','Yes','No');

% Only close if Yes is selected
if strcmp(buttonname,'Yes')
    delete(hObject);    %Close figure
end


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.Key
    case 'leftarrow'
        set(handles.leftradiobutton,'Value', 1)
        IMforCFAs('leftradiobutton_Callback',hObject, eventdata, handles)
    case 'rightarrow'
        set(handles.rightradiobutton,'Value', 1)        
        IMforCFAs('rightradiobutton_Callback',hObject, eventdata, handles)
    case 'z'
        IMforCFAs('nextbutton_Callback',hObject, eventdata, handles)
end
