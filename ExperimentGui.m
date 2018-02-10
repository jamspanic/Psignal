function varargout = ExperimentGui(varargin)
%This is where the parameters for the experiment are set.
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
function ExperimentGui_OpeningFcn(hObject, eventdata, handles, varargin)
set([handles.bStart,handles.bBack],'Enable','off');
handles.output = hObject;
guidata(hObject, handles);
global home globalparams datapath roothome
movegui(hObject,globalparams.disploc);
movegui(hObject,'onscreen');
handles.exptparams.FigureHandle = handles.figure1;
figure(handles.figure1);
%Get the list of sound/trial/beahvior objects from the directory:
if ~isdeployed
    SoundObjList = cat(1,dir([home filesep 'SoundObjects/@*']),...
        dir([home filesep 'SoundObjects' filesep '@*']));
    TrialObjList = cat(1,dir([home filesep 'TrialObjects/@*']),...
        dir([home filesep 'Experiments' filesep 'TrialObjects' filesep '@*']));
    BehaveObjList = cat(1,dir([home filesep 'BehaviorObjects/@*']),...
        dir([home filesep 'Experiments' filesep 'BehaviorObjects' filesep '@*']));
else
    load([home filesep 'ObjectLists.mat'])
end
temp = cell(1,length(SoundObjList));
[temp{:}] = deal(SoundObjList.name);
temp = strrep(temp,'@','');
[B,I,J] = unique(temp,'first');
temp={temp{sort(I)}};
set(handles.pPri,'String',temp);
set(handles.pPro,'String',sort({temp{:}, 'None'}));
temp = cell(1,length(TrialObjList));
[temp{:}] = deal(TrialObjList.name);
temp = strrep(temp,'@','');
[B,I,J] = unique(temp,'first');
temp={temp{sort(I)}};
set(handles.pTrialObject,'String',temp);
temp = cell(1,length(BehaveObjList));
[temp{:}] = deal(BehaveObjList.name);
temp = strrep(temp,'@','');
[B,I,J] = unique(temp,'first');
temp={temp{sort(I)}};
set(handles.pBhvControl,'String',temp);
%Load the default for each user from last experiment:
if exist([roothome filesep 'ExperimentGuiSettings.mat'])
    handles = load_settings(handles);
end
%Display the userdefinable fields for primary and probe:
handles = pPri_Callback(handles.pPri, eventdata, handles);
handles = pPro_Callback(handles.pPro, eventdata, handles);
% also, load the parameters of behaviour control:
handles = pBhvControl_Callback(handles.pBhvControl, eventdata, handles);
% and the user definable fields of trial object:
handles = pTrialObject_Callback(handles.pTrialObject, eventdata, handles);
set(handles.figure1,'Name',globalparams.Rig);
guidata(hObject,handles);
set([handles.bStart,handles.bBack],'Enable','on');
uiwait(handles.figure1);

%Output
function varargout = ExperimentGui_OutputFcn(hObject, eventdata, handles)
%Get default command line output from handles structure
varargout{1}= handles.output;
delete(handles.figure1);
%Save and load settings. These functions read the settings from the configuration file based on the animal
function varargout = load_settings(handles)
global home globalparams datapath roothome
animal = globalparams.Animal;
load ([roothome filesep 'ExperimentGuiSettings.mat']);
animalid =  find(strcmpi(animals.names,animal));
if isempty(animals.settings(animalid))
    settings = [];
else
    settings=animals.settings{animalid};
end
if ~isempty(settings)
    set(handles.cContTrain,'value',settings.ContinuousTraining);
    set(handles.eRepetition,'String',settings.Repetition);
    set(handles.eTrialBlock,'String',settings.TrialBlock);
    setString(handles.pTrialObject,settings.TrialObject);
    setString(handles.pBhvControl,settings.BehaviorControl);
    setString(handles.pPri,settings.PrimaryIndex);
    setString(handles.pPro,settings.ProbeIndex);
end
if nargout>0
    varargout{1}=handles;
end
%This function saves the current setting for the specified animal
function save_settings (handles)
global home globalparams  datapath roothome
animal = globalparams.Animal; 
if exist([roothome filesep 'ExperimentGuiSettings.mat'])
    load([roothome filesep 'ExperimentGuiSettings.mat']);
else
    animals.names=[];
    animals.settings=[];
    settings=[];
end
settings.ContinuousTraining = get(handles.cContTrain,'value');
settings.Repetition      = str2num(get(handles.eRepetition,'String'));
settings.TrialBlock      = str2num(get(handles.eTrialBlock,'String'));
settings.PrimaryIndex  = getString(handles.pPri);
settings.ProbeIndex     = getString(handles.pPro);
settings.BehaviorControl = getString(handles.pBhvControl);
settings.TrialObject     = getString(handles.pTrialObject);
animalid =  find(strcmpi(animals.names,animal));
if isempty(animalid)
    animals.names = [animals.names {animal}];
    animals.settings = [animals.settings {settings}];
else
    animals.settings{animalid}=settings;
end
save ([roothome filesep 'ExperimentGuiSettings.mat'],'animals');
function setString(h,String)
Strings = get(h,'String');
Value = find(strcmp(Strings,String));
if ~isempty(Value)
    set(h,'Value',Value);
end
function String = getString(h)
Strings = get(h,'String');
String = Strings{get(h,'Value')};
%Primary popup
function varargout = pPri_Callback(hObject, eventdata, handles)
%Get the userdefinable fields and display the options for the user
pripos = ExperimentGuiItems('PrimaryPosition');
priObject = getString(handles.pPri);
SavedObject = feval(priObject);
%Load setting of current sound object
SavedObject = ObjLoadSaveDefaults(SavedObject,'r',1); %index one means read last values for Primary
DefaultFields = get(SavedObject, 'UserDefinableFields');
PriHandles = [];
PriHandlesText = [];
if isfield(handles,'PriHandles')
    for cnt1=1:length(handles.PriHandles)
        delete(handles.PriHandles(cnt1));
        delete(handles.PriHandlesText(cnt1));
    end
end
for cnt1 = 1:length(DefaultFields)/3
    %length(DefaultFields) should be always a multiple of 3, because it had the field name, its style and its default value.
    CurrentField = DefaultFields((cnt1-1)*3+1:cnt1*3);
    %If the CurrentField is edit, get its value from the tempObject which has
    % the last values. But if its popupmenu, then load it with defaults
    % from object constructor (UserDefinableFields)"
    switch CurrentField{2}
        case 'popupmenu'
            DivPos = strfind(CurrentField{3},'|');
            SavePos = strfind(CurrentField{3},deblank(get(SavedObject, CurrentField{1})));
            if isempty(SavePos)
                SavePos=1;
            end
            DefaultValue = find(DivPos>SavePos,1);
            if isempty(DefaultValue)
                DefaultValue = length(DivPos)+1;
            end
            DefaultString = CurrentField{3};
        otherwise
            DefaultString = num2str(get(SavedObject, CurrentField{1}));
    end
    PriHandlesText(cnt1)=uicontrol('style','text','string',CurrentField{1},'FontWeight','bold',...
        'HorizontalAlignment','right','position',[pripos-[100 18*(cnt1-1)+3] 90 18]);
    PriHandles(cnt1) = uicontrol('Style',CurrentField{2},'String',DefaultString,'BackgroundColor',[1 1 1],'position',...
        [pripos-[0 18*(cnt1-1)] 130 18],'HorizontalAlignment','center');
    if strcmpi(CurrentField{2},'popupmenu')
        set(PriHandles(cnt1),'Value',DefaultValue);
    end
end
handles.PriHandles = PriHandles;
handles.PriHandlesText = PriHandlesText;
%This function is called at the begining too, for that case, return them
if nargout >0
    varargout{1} = handles;
else
    guidata(gcbo,handles);
end
%% Probe popup
function varargout = pPro_Callback(hObject, eventdata, handles)
%Get the userdefinable fields and display the options for the user
propos = ExperimentGuiItems('ProbePosition');
proObject = get(handles.pPro,'String');
proindex = get(handles.pPro,'Value');
proObject = proObject{proindex};
if ~strcmp(proObject,'None')
    tempObject = feval(proObject);
    %Load the last settings for this animal and probe
    tempObject = ObjLoadSaveDefaults (tempObject, 'r', 2); %index 2 means read the last values of Probe
    fields = get(tempObject, 'UserDefinableFields');
else
    fields=[];
end
proHandles = [];
proHandlesText = [];
%If current handled exist, delete them
if isfield(handles,'ProHandles')
    for cnt1=1:length(handles.ProHandles)
        delete(handles.ProHandles(cnt1));
        delete(handles.ProHandlesText(cnt1));
    end
end
for cnt1 = 1:length(fields)/3
    %length(fields) should be always a multiple of 3, because it had the field name, its style and its default value.
    field = fields((cnt1-1)*3+1:cnt1*3);
    %If the field is edit, get its value from the tempObject which has
    % the last values. But if its popupmenu, then load it with defaults
    % from object constructod (UserDefinableFields)"
    if strcmp(field{2},'popupmenu')
        tmp1 = strfind(field{3},'|');
        tmp2 = strfind(field{3},deblank(get(tempObject, field{1})));
        popvalue = find(tmp1>tmp2,1);
        if isempty(popvalue)
            popvalue = length(tmp1)+1;
        end
        default = field{3};
    else
        default = get(tempObject, field{1});
        default = num2str(default);
    end
    proHandlesText(cnt1)=uicontrol('style','text','string',field{1},'FontWeight','bold',...
        'HorizontalAlignment','right','position',[propos-[100 18*(cnt1-1)+3] 90 18]);
    proHandles(cnt1) = uicontrol('Style',field{2},'String',default,'BackgroundColor',[1 1 1],'position',...
        [propos-[0 18*(cnt1-1)] 130 18],'HorizontalAlignment','center');
    if strcmpi(field{2},'popupmenu')
        set(proHandles(cnt1),'value',popvalue);
    end
    if strcmpi(field{2},'checkbox')
        set(proHandles(cnt1),'value',ifstr2num(default));
    end
end
%Delete the temp object:
clear tempObject;
handles.ProHandles = proHandles;
handles.ProHandlesText = proHandlesText;
if nargout >0
    varargout{1} = handles;
else
    guidata(gcbo,handles);
end
%% Behavior control
function handles = pBhvControl_Callback(hObject, eventdata, handles)
%When the user select the Behavior control routine, set the default
% params from the past and if it does not exist load it from the file:
BehaveObject = getString(handles.pBhvControl);
BehaveObject = feval(BehaveObject);
BehaveObject = ObjLoadSaveDefaults (BehaveObject,'r',1); % Load the defaults for current user:
handles.BehaveObject = BehaveObject; clear BehaveObject;
if nargout >0
    varargout{1} = handles;
else
    guidata(gcbo,handles);
end
%% Parameters Gui
function bParam_Callback(hObject, eventdata, handles)
%Parameters button, open parameters gui and get the values from the user:
BehaveObject = handles.BehaveObject;
UserInput = 0;
fields = get(BehaveObject, 'UserDefinableFields');
if ~isempty(fields)
    for cnt1 = 1:3:length(fields)-1;
        param(1+(cnt1-1)/3).text = fields{cnt1};
        param(1+(cnt1-1)/3).style = fields{cnt1+1};
        if strcmp(fields{cnt1+1},'popupmenu')
            tmp1 = strfind(fields{cnt1+2},'|');
            tmp2 = strfind(fields{cnt1+2},get(BehaveObject, fields{cnt1}));
            popvalue = find(tmp1>tmp2,1);
            if isempty(popvalue)
                popvalue = length(tmp1)+1;
            end
            default = fields{cnt1+2};
            default = {fields{cnt1+2}, popvalue};
        else
            default = get(BehaveObject, fields{cnt1});
        end
        param(1+(cnt1-1)/3).default = default;
    end
    UserInput = ParameterGUI (param,'Behavior Parameters','bold','center');
    if ~isnumeric(UserInput) %User did not press cancel, so change them:
        for cnt1 = 1:length(param);
            UserInput{cnt1}=ifstr2num(UserInput{cnt1});
            if isnumeric(UserInput{cnt1}) & ~isempty(UserInput{cnt1})
                BehaveObject = set(BehaveObject, fields{1+(cnt1-1)*3}, (UserInput{cnt1}));
            elseif ischar(UserInput{cnt1})
                BehaveObject = set(BehaveObject, fields{1+(cnt1-1)*3}, strtok(UserInput{cnt1}));
            end
        end
        %Save it as last values and update the object in handles:
        ObjLoadSaveDefaults(BehaveObject,'w', 1);
        handles.BehaveObject = BehaveObject;
        guidata(gcbo,handles);
    end
else
    warndlg(sprintf('%s mode does not have any parameters!',class(BehaveObject)));
end
%% Trial object popup
function varargout = pTrialObject_Callback(hObject, eventdata, handles)
TrialObjList = get(handles.pTrialObject,'String');
[junk TrialObject] = evalc(TrialObjList{get(handles.pTrialObject,'Value')});
TrialObject = ObjLoadSaveDefaults (TrialObject,'r',1);
TrialHandles = [];
fields = get(TrialObject,'UserDefinableFields');
%If it already exists, delete it and recreate it:
if isfield(handles,'TrialHandles'),
    for cnt1=1:length(handles.TrialHandles)
        delete(handles.TrialHandles(cnt1));
        delete(handles.TrialHandlesText(cnt1));
    end
end
trialpos = ExperimentGuiItems ('ExprimentparamsPosition');
if length(fields)./3 > 6,
    useparmgui=1;
else
    useparmgui=0;
end
%Display them on the screen:
for cnt1 = 1:length(fields)/3
    %length(fields) should be always a multiple of 3, because it had the field name, its style and its default value.
    field = fields((cnt1-1)*3+1:cnt1*3);
    if strcmp(field{2},'popupmenu')
        tmp1 = strfind(field{3},'|');
        tmp2 = strfind(field{3},get(TrialObject, field{1}));
        popvalue = find(tmp1>tmp2,1);
        if isempty(popvalue)
            popvalue = length(tmp1)+1;
        end
        default = field{3};
    else
        default = num2str(get(TrialObject, field{1}));
    end
    TrialHandlesText(cnt1)=uicontrol('style','text','string',field{1},'FontWeight','bold',...
        'HorizontalAlignment','right','position',[trialpos-[130 18*(cnt1-1)+4] 120 18]);
    TrialHandles(cnt1) = uicontrol('Style',field{2},'String',default,'BackgroundColor',[1 1 1],'position',...
        [trialpos-[0 18*(cnt1-1)] 120 18]);
    if strcmpi(field{2},'popupmenu')
        set(TrialHandles(cnt1),'value',popvalue);
    end
    if useparmgui,
        set(TrialHandlesText(cnt1),'Visible','off');
        set(TrialHandles(cnt1),'Visible','off');
    end
end
%% Save their handles in gui: (trialHandles are module parameters)
handles.TrialObject = TrialObject;
handles.TrialHandles = TrialHandles;
handles.TrialHandlesText = TrialHandlesText;
if useparmgui,
    set(handles.bTrialObjectParameters,'Visible','on');
    set(handles.textTrialObjectParameters,'Visible','on');
    update_textTrialObjectParameters(handles)
else
    set(handles.bTrialObjectParameters,'Visible','off');
    set(handles.textTrialObjectParameters,'Visible','off');
end
if nargout >0
    varargout{1} = handles;
else
    guidata(gcbo,handles);
end
%% Trial object paarameter button (Visible if too many parameters to fit on panel)
function bTrialObjectParameters_Callback(hObject, eventdata, handles)
TrialObject = handles.pTrialObject;
UserInput = 0;
fields = get(TrialObject, 'UserDefinableFields');
for cnt1 = 1:3:length(fields)-1;
    param(1+(cnt1-1)/3).text = fields{cnt1};
    param(1+(cnt1-1)/3).style = fields{cnt1+1};
    if strcmp(fields{cnt1+1},'popupmenu')
        tmp1 = strfind(fields{cnt1+2},'|');
        tmp2 = strfind(fields{cnt1+2},get(handles.TrialHandles(1+(cnt1-1)/3), 'value'));
        popvalue = find(tmp1>tmp2,1);
        if isempty(popvalue)
            popvalue = length(tmp1)+1;
        end
        default = fields{cnt1+2};
        default = {fields{cnt1+2}, get(handles.TrialHandles(1+(cnt1-1)/3), 'value')};
    else
        default = get(handles.TrialHandles(1+(cnt1-1)/3), 'string');
    end
    param(1+(cnt1-1)/3).default = default;
end
UserInput = ParameterGUI (param,'Trial Object Parameters','bold','center');
if ~isnumeric(UserInput) % user did not press cancel, so change them:
    for cnt1 = 1:length(param);
        if strcmp(param(cnt1).style,'popupmenu')
            tmp1 = strfind(param(cnt1).default{1},'|');
            tmp2 = strfind(param(cnt1).default{1},strtrim(UserInput{cnt1}));
            popvalue = find(tmp1>tmp2,1);
            if isempty(popvalue)
                popvalue = length(tmp1)+1;
            end
            set(handles.TrialHandles(cnt1), 'value', popvalue);
        else
            set(handles.TrialHandles(cnt1), 'string', UserInput{cnt1});
        end
    end
    update_textTrialObjectParameters(handles)
    guidata(gcbo,handles);
end
function update_textTrialObjectParameters(handles)
stext={};
fields = get(handles.pTrialObject, 'UserDefinableFields');
for cnt1 = 1:3:length(fields)-1;
    if strcmp(fields{cnt1+1},'popupmenu')
        v=get(handles.TrialHandles(1+(cnt1-1)/3), 'value');
        stext{1+(cnt1-1)/3}=[fields{cnt1} ': ' num2str(v)];
    else
        v=get(handles.TrialHandles(1+(cnt1-1)/3), 'string');
        stext{1+(cnt1-1)/3}=[fields{cnt1} ': ' v];
    end
end
set(handles.textTrialObjectParameters,'string',stext,'HorizontalAlignment','left','FontSize',7);
%% Start button
function bStart_Callback(hObject, eventdata, handles)
% create an instance of PrimaryProbe object and update its fields from
% user data. Then save the object and call primary probe script.
% first, read the pTrialObject from handles:
set(handles.bStart,'Enable','off');
set(handles.bBack,'Enable','off');
drawnow;
TrialObject = handles.TrialObject;
%% Update the general fields based on Gui inputs:
for cnt1 = 1:length(handles.TrialHandles);
    field = get(handles.TrialHandlesText(cnt1), 'String');
    tempSt = get(handles.TrialHandles(cnt1),'String');
    tempIn = get(handles.TrialHandles(cnt1),'Value');
    if tempIn==0
        value = tempSt;
    elseif iscell(tempSt)
        value=tempSt{tempIn};
    else
        value = tempSt(tempIn,:);
    end
    [junk tempObj] = evalc(class(TrialObject));
    if isnumeric(get(tempObj, field)) & ~isempty(get(tempObj, field))
        value = ifstr2num(value);
    elseif ischar(value)
        value = strtok(value);
    end
    TrialObject = set(TrialObject, field, value);
end
%%  Create the Primary Class:
PriName = get(handles.pPri,'String');
index = get(handles.pPri,'Value');
PriName = PriName{index};
[junk PriObject] = evalc(PriName);
if ~isempty(handles.PriHandles)
    for cnt1 = 1:length(handles.PriHandles)
        field = get(handles.PriHandlesText(cnt1), 'String');
        tempSt = get(handles.PriHandles(cnt1),'String');
        tempIn = get(handles.PriHandles(cnt1),'Value');
        if tempIn==0
            value = (tempSt);
        elseif iscell(tempSt)
            value=tempSt{tempIn};
        else
            value=tempSt(tempIn,:);
        end
        [junk tempObj]  = evalc(class(PriObject));
        if isnumeric(get(tempObj, field)) & ~isempty(get(tempObj, field))
            value = ifstr2num(value);
        end
        PriObject = set(PriObject, field, value);
    end
end
%% If probe is defined, create it
ProName = get(handles.pPro,'String');
index = get(handles.pPro,'Value');
ProName = ProName{index};
if ~strcmp(ProName,'None')
    [junk ProObject] = evalc(ProName);
    if ~isempty(handles.ProHandles)
        for cnt1 = 1:length(handles.ProHandles)
            field = get(handles.ProHandlesText(cnt1), 'String');
            tempSt = get(handles.ProHandles(cnt1),'String');
            tempIn = get(handles.ProHandles(cnt1),'Value');
            if tempIn==0
                value = (tempSt);
            elseif iscell(tempSt)
                value=tempSt{tempIn};
            else value=tempSt(tempIn,:);
            end
            if strcmpi(get(handles.ProHandles(cnt1),'Style'),'checkbox'),
                value = tempIn;
            end
            [junk tempObj]  = evalc(class(ProObject));
            if isnumeric(get(tempObj, field)) & ~isempty(get(tempObj, field))
                value = ifstr2num(value);
            end
            ProObject = set(ProObject, field, value);
        end
    end
else
    ProObject = [];
    ProName='None';
end
%%  Construct the PrimaryProbe Object:
TrialObject = set(TrialObject, 'PrimaryHandle', PriObject);
TrialObject = set(TrialObject, 'ProbeHandle', ProObject);
exptparams = handles.exptparams;
exptparams.FigureHandle = handles.figure1;
% % Obtain experiment parameters: pass the object in Object field of exptparams:
exptparams.TrialObject = TrialObject;
exptparams.runclass = get(TrialObject,'RunClass');
exptparams.ContinuousTraining = get(handles.cContTrain,'value');
%eRepetition
exptparams.Repetition = ifstr2num(get(handles.eRepetition,'String'));
%Trial Block
exptparams.TrialBlock = ifstr2num(get(handles.eTrialBlock,'String'));
%Read the Behavior parameters of Behavior:
exptparams.BehaveObject = handles.BehaveObject;
%Classes:
exptparams.BehaveObjectClass = class(exptparams.BehaveObject);
exptparams.TrialObjectClass = class(TrialObject);
if isfield(get(exptparams.TrialObject),'SaveData') && strcmpi(get(exptparams.TrialObject,'SaveData'),'No')
    exptparams.outpath='X';
end
%% Save the current setting for PrimaryProbe, Primary and Probe objects:
ObjLoadSaveDefaults(TrialObject,'w', 1);
ObjLoadSaveDefaults(PriObject,'w',1); % save in Primary profile (1)
if ~isempty(ProObject)
    ObjLoadSaveDefaults(ProObject,'w',2); % save in Probe profile (2)
end
save_settings(handles);
handles.output = exptparams;
guidata(gcbo, handles);
uiresume;
%% Back button
function bBack_Callback(hObject, eventdata, handles)
global home;
if isempty(home) startup;end
handles.output = [];
guidata(gcbo, handles);
uiresume;
%% Callbacks
function edit8_Callback(hObject, eventdata, handles)
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit4_Callback(hObject, eventdata, handles)
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu1_Callback(hObject, eventdata, handles)
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu2_Callback(hObject, eventdata, handles)
function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit6_Callback(hObject, eventdata, handles)
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit7_Callback(hObject, eventdata, handles)
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit1_Callback(hObject, eventdata, handles)
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_Callback(hObject, eventdata, handles)
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit3_Callback(hObject, eventdata, handles)
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit5_Callback(hObject, eventdata, handles)
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pPri_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pPro_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pBhvControl_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function eRepetition_Callback(hObject, eventdata, handles)
function eRepetition_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit14_Callback(hObject, eventdata, handles)
function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit15_Callback(hObject, eventdata, handles)
function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit16_Callback(hObject, eventdata, handles)
function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pTrialObject_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function eTrialBlock_Callback(hObject, eventdata, handles)
function eTrialBlock_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pOnlineWaveform_Callback(hObject, eventdata, handles)
function pOnlineWaveform_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function cContTrain_Callback(hObject, eventdata, handles)
%% Local Functions
function varargout = ExperimentGuiItems (field)
switch field
    case 'ExprimentparamsPosition'         % position of module properties
        varargout{1} = [405 645];
    case 'PrimaryPosition'            % position of Primary properties
        varargout{1} = [135 380];
    case 'ProbePosition'               % position of Probe properties
        varargout{1} = [395 380];
end
