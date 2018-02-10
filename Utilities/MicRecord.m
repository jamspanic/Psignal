function AllData = MicRecord(seconds, device, fs, diffsingle, sound)
if nargin < 3
    fs = 200000;
end
if nargin < 4
    diffsingle = 'SingleEnded';
end
if nargin < 5
    sound = zeros(fs*seconds,1);
end
global globalparams HW home diffsingle
caller=dbstack;
if strcmp(caller(1).name,'Psignal') && ~exist('home','var')
    clear classes
    clear global
end
%% Setup pathways, rig and device id's
home=fileparts(which('Psignal'));
load([home '\PsignalConfig.mat'])
globalparams.Rig = rig;
globalparams.disploc = disploc;
globalparams.Device = device;
configDAQ;
HW.params.fsAO=fs;
HW.params.fsAI=fs;
HW.AO.Rate =   HW.params.fsAO;
IOStopAcquisition(HW);
HW=IOSetAnalogInDuration(HW,seconds);
IOLoadSound(HW, sound);
fprintf('\nBegin Recording in 3...')
pause(1)
fprintf('2...')
pause(1)
fprintf('1...\n')
pause(1)
fprintf('Recording Now...')
IOStartAcquisition(HW);
IsRunning=1;
while IsRunning
    IsRunning=HW.AO.IsRunning;
    pause(eps);
    fprintf('.')
end
IOStopAcquisition(HW);
fprintf('\nDone Recording!\n')
%% Collect data
[AllData AINames] = IOReadAIData(HW);
figure
y=AllData-mean(AllData);
fs = HW.params.fsAI;
t=0:1/fs:(length(y)/fs)-(1/fs);
subplot(2,1,1)
plot(t,y)
xlabel('Time (s)')
subplot(2,1,2)
f=linspace(0,fs,length(y));
plot(f,abs(fft(y)))
xlabel('Frequency (Hz)')
xlim([0 fs/2])
function configDAQ
global globalparams HW diffsingle
ShutdownHW([]);
HW=[];
HW.params.NumAOChan=1;
HW.params.DAQ = 'ni';
HW.params.fsAO=200000;
HW.params.fsAI=200000;
DAQID = globalparams.Device; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
daq.reset;
%% Analog IO
HW.AI = daq.createSession('ni');
HW.AI.Rate=HW.params.fsAI;
HW.AO = daq.createSession('ni');
HW.AO.Rate=HW.params.fsAO;
HW.AIch(1)=addAnalogInputChannel(HW.AI, DAQID,  1, 'Voltage');
HW.AOch(1)=addAnalogOutputChannel(HW.AO, DAQID, 0, 'Voltage');
HW.AIch(1).Name = 'Microphone';
HW.AOch(1).Name = 'SoundOut';
HW.params.LineReset = [0 0];
HW.params.LineTrigger = [];
HW.AIch(1).Range = [-1 1];
if strcmpi(diffsingle,'SingleEnded')
    HW.AIch(1).TerminalConfig = 'SingleEnded';
else
    HW.AIch(1).TerminalConfig = 'Differential';
end
HW.AOch(1).Range = [-10 10];
%% Assign HW params to globalparams
globalparams.HWparams = HW.params;