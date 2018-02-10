function Psignal
% Psignal is a Matlab toolbox for controlling behavioral neuroscience experiments
% using National Instruments DAQ hardware. See documentation for installation and
% operational details. Psignal runs in 64-bit Matlab, using the session-based interface.
% Psignal uses a semi-object-oriented language, and is built around the
% "ExperimentGui," originally written into Baphy (Mesgarani, David, Englitz, Francis,
% et al, Neural Systems Lab, University of Maryland).
% Nikolas A. Francis 2017

clear global
daq.reset;
global home globalparams datapath exptparams HW ResultsFigure roothome
clc
disp('*** Starting Psignal ***');
quit_Psignal=0;
warning('off','MATLAB:dispatcher:InexactMatch');
while ~quit_Psignal,
    
    %Clear open figures
    if exist('exptparams','var') && isfield(exptparams,'FigureHandle')
        try
            close(exptparams.FigureHandle)
        catch
        end
    end
    
    %Determine home path based on using standalone vs within matlab
    if ~isdeployed
        home=fileparts(which('Psignal'));
    else
        [status, result] = system('path');
        home = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
        home = home(1:strfind(home,'application')-1);
    end
    
    %Load PsignalConfig file, which contains information about which rig is
    %being used for experiments
    if isdeployed
        load([home '\PsignalConfig.mat'])
    elseif ~isdeployed && isempty(roothome)
        [FileName FilePath] = uigetfile([home '\*.mat'],'Load PsignalConfig File');
        load([FilePath '\' FileName])
    end
    globalparams.Rig = rig;
    globalparams.disploc = disploc;
    
    %Determine which DAQ devices are available
    Devices=[];
    if ~strcmpi(DevID, 'OSIO')
                dev=daq.getDevices;
                for i = 1:length(dev)
                    if strfind(dev(i).ID,DevID);
                        Devices = [Devices; dev(i).ID];
                    end
                end
%         Devices = [Devices;'Audio2'];
        if isempty(Devices)
            warning('DAQ device not found')
        end
    end
    globalparams.Devices = {Devices; 'OSIO'};
    
    %Open MainGui
    [quit_Psignal globalparams]= MainGui;
    if quit_Psignal
        break;
    end
    
    %Initialize DAQ settings
    disp('Initializing hardware...');
    if  strcmpi(globalparams.Device,'OSIO')
        [HW globalparams] = ConfigAudio(globalparams);
    else
        [HW globalparams] = ConfigNI(globalparams);
    end
    
    %Open ExperimentGui
    exptparams=ExperimentGui;
    
    %Define file names
    if ~isempty(exptparams),
        globalparams.outpath=globalparams.DataPath;
        %Output files
        if globalparams.outpath(end)~=filesep,
            globalparams.outpath=[globalparams.outpath filesep];
        end
        setcount=0;
        
        outfile='';
        while isempty(outfile) || exist([outfile,'.mat'],'file'),
            setcount=setcount+1;
            %Define file names with or without physiology
            if strcmpi(globalparams.Physiology,'~Phys')
                outfile=[globalparams.outpath globalparams.Animal filesep ...
                    exptparams.runclass '_' globalparams.Animal '_' ...
                    datestr(now,'yyyy_mm_dd') '_' num2str(setcount)];
            elseif strcmpi(globalparams.Physiology,'Phys')
                outfile=[globalparams.outpath globalparams.Animal filesep ...
                    exptparams.runclass '_' globalparams.Animal '_' ...
                    datestr(now,'yyyy_mm_dd') '_Phys_' num2str(setcount)];
            end
        end
        globalparams.mfilename=[outfile,'.mat'];
        %         globalparams.datafilename=[outfile,'.daq'];
    end
    
    %Check to see if outpath is accesible
    if ~isempty(exptparams) && ~exist(globalparams.outpath,'dir') && ...
            ~strcmp(upper(globalparams.outpath),'X')
        warning(['The output path: ' globalparams.outpath ...
            ' is not available, can not continue']);
        exptparams = [];
    end
    if ~isempty(exptparams) && ~exist(fileparts(globalparams.mfilename),'dir') && ...
            ~isempty(globalparams.mfilename),
        success = mkdir(fileparts(globalparams.mfilename));
        success = mkdir([fileparts(globalparams.mfilename) filesep 'tmp']);
        success = mkdir([fileparts(globalparams.mfilename) filesep 'raw']);
        if ~success,
            warning(['The file path: ' fileparts(globalparams.mfilename) ...
                ' is not available, can not continue']);
            exptparams = [];
        end
    end
    
    %Run the experiment
    exptevents=[];
    if ~isempty(exptparams),
        globalparams.ExperimentComplete=0;
        disp('Initializing mfile...');
        [exptevents,exptparams]=RunExperiment;
        disp('Shutting down hardware...');
        ShutdownHW(HW);
    end
    
    %Save the results of the experiment
    if ~isempty(exptevents)
        if isfield(exptevents,'Trial')
            globalparams.rawfilecount=max(cat(1,exptevents.Trial));
            if isfield(exptparams,'RepetitionCount'),
                RepCount=exptparams.RepetitionCount;
            elseif isfield(exptparams,'TotalRepetitions'),
                RepCount=exptparams.TotalRepetitions;
            elseif isfield(exptparams,'repcount'),
                RepCount=exptparams.repcount;
            else
                RepCount=0;
            end
        else
            globalparams.rawfilecount = 0;
        end
        globalparams.ExperimentComplete=1;
        
        %Update m-file
        disp('Updating mfile...');
        WriteMFile(globalparams,exptparams,exptevents)
        
        %Save behavior figures to png
        if ~strcmpi(exptparams.BehaveObjectClass,'Passive')
            if isfield(exptparams,'Figure')
                exptparams.ResultsFigure=exptparams.Figure;
                SaveBehaviorFigure(exptparams,outfile);
            end
        end
    end
end
disp('*** Closing Psignal ***');