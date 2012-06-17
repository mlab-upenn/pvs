% Copyright 2012 Sriram Radhakrishnan, Varun Sampath, Shilpa Sarode
% 
% This file is part of PVS.
% 
% PVS is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
% 
% PVS is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
% PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with PVS.  If not, see <http://www.gnu.org/licenses/>.

function varargout = PVS_GUI(varargin)
% PVS_GUI MATLAB code for PVS_GUI.fig
%      PVS_GUI, by itself, creates a new PVS_GUI or raises the existing
%      singleton*.
%
%      H = PVS_GUI returns the handle to a new PVS_GUI or the handle to
%      the existing singleton*.
%
%      PVS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PVS_GUI.M with the given input arguments.
%
%      PVS_GUI('Property','Value',...) creates a new PVS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PVS_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PVS_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on PVS_GUI's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: PVS_GUI, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PVS_GUI

% Last Modified by PVS_GUI v2.5 05-Apr-2012 00:33:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PVS_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PVS_GUI_OutputFcn, ...
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



% --- Executes just before PVS_GUI is made visible.
function PVS_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PVS_GUI (see VARARGIN)

% Choose default command line output for PVS_GUI
handles.output = hObject;
set(hObject,'Name','Pacemaker Verification System');

% set background color thresholds
handles.cThresh = [50 120];

% Update handles structure
guidata(hObject, handles);

% Add heart model options
global arrOptions;
global arrOptionSAVals;
global arrOptionAVVals;
arrOptions = {'Select Heart Model', 'Normal Sinus Rhythm', ...
    'Bradycardia', 'ELT', 'Custom'};
arrOptionSAVals = {'', '600', '1067', '600', ''};
arrOptionAVVals = {'', '33', '133', '33', ''};
set(handles.pickArr, 'String', arrOptions);

% Insert Logo
logo = imread('pennLogo','png');
pic = imshow(logo, 'Parent',handles.pennLogo);

% Setup heartbeat sound
global HBsound;
global ErrorSound;
HBsound = wavread('heartbeat.wav');
ErrorSound = wavread('high.wav');

% Populate COM port field if serial ports are available
serial = instrhwinfo('serial');
ports = serial.SerialPorts;
if length(ports) == 1
    port = ports{1};
    port = port(4:end);
    set(handles.comField, 'String', port);
end


% UIWAIT makes PVS_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PVS_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in pickArr.
function pickArr_Callback(hObject, eventdata, handles)
% hObject    handle to pickArr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pickArr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pickArr

global arrOptions;
global arrOptionSAVals;
global arrOptionAVVals;
contents = cellstr(get(hObject,'String'));
selection = contents(get(hObject,'Value'));
for i=1:length(arrOptions)
    if strcmp(selection, arrOptions{i})
        set(handles.SArest,'String', arrOptionSAVals{i});
        set(handles.AVdelay,'String', arrOptionAVVals{i});
    end
end
    



% --- Executes during object creation, after setting all properties.
function pickArr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pickArr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BPM_Callback(hObject, eventdata, handles)
% hObject    handle to BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BPM as text
%        str2double(get(hObject,'String')) returns contents of BPM as a double


% --- Executes during object creation, after setting all properties.
function BPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in toggleHB.
function toggleHB_Callback(hObject, eventdata, handles)
% hObject    handle to toggleHB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleHB
global enableBeat;
global flush;

enableBeat = ~enableBeat;
flush = 1;
% clear draw_new_point_gui


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over toggleHB.
function toggleHB_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to toggleHB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipanel2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles
position = get(handles.figure1,'Position');
set(handles.BPM,'String',122);

if position(3) > 220
    set(handles.SArestName,'FontSize',12);
    set(handles.AVdelayName,'FontSize',12);
    set(handles.SArest,'FontSize',12);
    set(handles.AVdelay,'FontSize',12);
    
    set(handles.setParams,'FontSize',16);
    set(handles.sendPAC,'FontSize',12);
    set(handles.sendPVC,'FontSize',12);
    set(handles.paceSwitch,'FontSize',12);
    
    set(handles.ecgtext,'FontSize',11);
    set(handles.apacetext,'FontSize',11);
    set(handles.vpacetext,'FontSize',11);
    
    set(handles.titleField,'FontSize',24);
    set(handles.bpmlabel,'FontSize',12);
    
    set(handles.COMname,'FontSize',14);
    set(handles.comField,'FontSize',14);
    
    set(handles.units1,'FontSize',14);
    set(handles.units2,'FontSize',14);
    
    set(handles.start,'FontSize',30);
    set(handles.toggleHB,'FontSize',24);
    
    set(handles.BPM,'FontSize',80);
else
    set(handles.SArestName,'FontSize',8);
    set(handles.AVdelayName,'FontSize',8);
    set(handles.SArest,'FontSize',8);
    set(handles.AVdelay,'FontSize',8);
    
    set(handles.setParams,'FontSize',11);
    set(handles.sendPAC,'FontSize',10);
    set(handles.sendPVC,'FontSize',10);
    set(handles.paceSwitch,'FontSize',10);
    
    set(handles.ecgtext,'FontSize',8);
    set(handles.apacetext,'FontSize',8);
    set(handles.vpacetext,'FontSize',8);
    
    set(handles.titleField,'FontSize',17);
    set(handles.bpmlabel,'FontSize',8);
    
    set(handles.COMname,'FontSize',11);
    set(handles.comField,'FontSize',11);
    
    set(handles.units1,'FontSize',11);
    set(handles.units2,'FontSize',11);
    
    set(handles.start,'FontSize',20);
    set(handles.toggleHB,'FontSize',16);
    
    set(handles.BPM,'FontSize',60);
end


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global serialObj;
global enableBeat;
global flush;

% Cleanup code
delete(instrfindall);
delete(timerfindall);
clear draw_new_point_gui;

enableBeat = 1;
flush = 1;

% Create PQRST Wave
% beat = 3*ecg(500);
% pqrst = sgolayfilt(beat,0,5);

% Create Serial Object
port = get(handles.comField, 'String');
if isempty(port)
    disp('You must enter a COM port number');
    return;
end
serialObj = serial(['COM' port]);
serialObj.BaudRate = 115200;
fopen(serialObj);
serialObj.ReadAsyncMode = 'continuous';

axisObj = [handles.ECG];


% % Create Timer Object
% timerObj = timer;
% set(timerObj, 'Period', 0.001);
% set(timerObj, 'executionMode', 'fixedRate');
% set(timerObj, 'TimerFcn', {@draw_new_point_gui, beat, pqrst,...
%     axisObj, serialObj, handles});
% start(timerObj);

% Start GUI
init_serial_gui(serialObj,axisObj,handles)



function AVdelayName_Callback(hObject, eventdata, handles)
% hObject    handle to AVdelayName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AVdelayName as text
%        str2double(get(hObject,'String')) returns contents of AVdelayName as a double


% --- Executes during object creation, after setting all properties.
function AVdelayName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AVdelayName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SArestName_Callback(hObject, eventdata, handles)
% hObject    handle to SArestName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SArestName as text
%        str2double(get(hObject,'String')) returns contents of SArestName as a double


% --- Executes during object creation, after setting all properties.
function SArestName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SArestName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SArest_Callback(hObject, eventdata, handles)
% hObject    handle to SArest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SArest as text
%        str2double(get(hObject,'String')) returns contents of SArest as a double
set(handles.pickArr, 'Value', 5);

% --- Executes during object creation, after setting all properties.
function SArest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SArest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AVdelay_Callback(hObject, eventdata, handles)
% hObject    handle to AVdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AVdelay as text
%        str2double(get(hObject,'String')) returns contents of AVdelay as a double
set(handles.pickArr, 'Value', 5);



% --- Executes during object creation, after setting all properties.
function AVdelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AVdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setParams.
function setParams_Callback(hObject, eventdata, handles)
% hObject    handle to setParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global serialObj;
CLOCK = 1.5; %1.5KHz

disp(get(handles.SArest,'String'));
SAforw = uint16(str2num(get(handles.SArest,'String')));
AVdelay = uint16(str2num(get(handles.AVdelay,'String')));
SAforw = round(SAforw * CLOCK);
AVdelay = round(AVdelay * CLOCK);
fprintf('Send SA rest of %d, AV delay of %d\n', SAforw, AVdelay);
set_rate(serialObj, SAforw, AVdelay, 0, 0, 0, 0);


% --- Executes on button press in sendPAC.
function sendPAC_Callback(hObject, eventdata, handles)
% hObject    handle to sendPAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global serialObj;
fprintf('Send PAC\n');
% set_rate will use previous values for SA/AV
set_rate(serialObj, 0, 0, 1, 0, 0, 0);


% --- Executes on button press in sendPVC.
function sendPVC_Callback(hObject, eventdata, handles)
% hObject    handle to sendPVC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global serialObj;
fprintf('Send PVC\n');
% set_rate will use previous values for SA/AV
set_rate(serialObj, 0, 0, 0, 1, 0, 0);


% --- Executes during object creation, after setting all properties.
function pennLogo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pennLogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate pennLogo



function comField_Callback(hObject, eventdata, handles)
% hObject    handle to comField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of comField as text
%        str2double(get(hObject,'String')) returns contents of comField as a double


% --- Executes during object creation, after setting all properties.
function comField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function bpmlabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpmlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in paceSwitch.
function paceSwitch_Callback(hObject, eventdata, handles)
% hObject    handle to paceSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global serialObj;
persistent isPace;

if isempty(isPace)
    isPace = 1;
end

if isPace
    set(hObject, 'BackgroundColor', 'r', 'String', 'Pacemaker Disconnected');
    isPace = 0;
else
    set(hObject, 'BackgroundColor', 'g', 'String', 'Pacemaker Connected');    
    isPace = 1;
end
set_rate(serialObj, 0, 0, 0, 0, isPace, 1);
