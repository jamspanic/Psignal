function varargout = ExperimentGui(varargin)
%EXPERIMENTGUI MATLAB code file for ExperimentGui.fig
%      EXPERIMENTGUI, by itself, creates a new EXPERIMENTGUI or raises the existing
%      singleton*.
%
%      H = EXPERIMENTGUI returns the handle to a new EXPERIMENTGUI or the handle to
%      the existing singleton*.
%
%      EXPERIMENTGUI('Property','Value',...) creates a new EXPERIMENTGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ExperimentGui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      EXPERIMENTGUI('CALLBACK') and EXPERIMENTGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in EXPERIMENTGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExperimentGui

% Last Modified by GUIDE v2.5 10-Feb-2018 19:12:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExperimentGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ExperimentGui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before ExperimentGui is made visible.
function ExperimentGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ExperimentGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExperimentGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ExperimentGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in bStart.
function bStart_Callback(hObject, eventdata, handles)
% hObject    handle to bStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in bBack.
function bBack_Callback(hObject, eventdata, handles)
% hObject    handle to bBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pBhvControl.
function pBhvControl_Callback(hObject, eventdata, handles)
% hObject    handle to pBhvControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pBhvControl contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pBhvControl


% --- Executes during object creation, after setting all properties.
function pBhvControl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pBhvControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bParam.
function bParam_Callback(hObject, eventdata, handles)
% hObject    handle to bParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in bHelp.
function bHelp_Callback(hObject, eventdata, handles)
% hObject    handle to bHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pPro.
function pPro_Callback(hObject, eventdata, handles)
% hObject    handle to pPro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pPro contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pPro


% --- Executes during object creation, after setting all properties.
function pPro_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pPro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pPri.
function pPri_Callback(hObject, eventdata, handles)
% hObject    handle to pPri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pPri contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pPri


% --- Executes during object creation, after setting all properties.
function pPri_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pPri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eRepetition_Callback(hObject, eventdata, handles)
% hObject    handle to eRepetition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eRepetition as text
%        str2double(get(hObject,'String')) returns contents of eRepetition as a double


% --- Executes during object creation, after setting all properties.
function eRepetition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eRepetition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eTrialBlock_Callback(hObject, eventdata, handles)
% hObject    handle to eTrialBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eTrialBlock as text
%        str2double(get(hObject,'String')) returns contents of eTrialBlock as a double


% --- Executes during object creation, after setting all properties.
function eTrialBlock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eTrialBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pTrialObject.
function pTrialObject_Callback(hObject, eventdata, handles)
% hObject    handle to pTrialObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pTrialObject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pTrialObject


% --- Executes during object creation, after setting all properties.
function pTrialObject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pTrialObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cContTrain.
function cContTrain_Callback(hObject, eventdata, handles)
% hObject    handle to cContTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cContTrain


% --- Executes on button press in bTrialObjectParameters.
function bTrialObjectParameters_Callback(hObject, eventdata, handles)
% hObject    handle to bTrialObjectParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
