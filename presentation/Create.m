function Create(sub)
global params;
UNIT = 0.8;

trdir = 'D:\Neurofeedback\';

% initial variables calculated from rtconfig
rtconf = fullfile(trdir,'rtconfig.txt');
while ~exist(rtconf,'file')
    sfx='conventional'; %change to 'conventional' or 'novel' accordingly
    if exist(fullfile(fileparts(mfilename('fullpath')),['rtconfig_' sfx '.txt']),'file')
        rtconf = fullfile(fileparts(mfilename('fullpath')),['rtconfig_' sfx '.txt']);
        break;
    end
end
ini = IniFile(rtconf);
nbaseline = ini.reference.base_vols;
nactive = ini.reference.ref_act;
ncontrol = ini.reference.ref_control;
ncycle = ini.reference.ref_cycles;
isopcond = strcmp(ini.reference.ref_type,'opcond');
ndeactive = ini.reference.ref_deact;
if isopcond
    ndeactive = nactive;
    ncontrol = (ncontrol-ndeactive)/2;
end
vols = ini.timing.volumes;
ref = nfb_reference(ini);
vec = ref.vec;
params.fb_vect = vec.fb_vect';
params.fb_vect(end:vols) = false;

params.fb.emul = true; % false; using mouse position
params.pulse.emul = false; % false; using timer
params.pulse.wait = 1; % wait before read pulse
params.st_wait = 0.6;
params.TR = 2; % TR in s for emulation

if isempty(sub)
    nbaseline = 5; % 1; number of baseline scans
    ncycle = 2; % 2; number of cycles
    ncontrol = 5; % 4; number of control scans
    nactive = 5; % 4; number of active scans
    vols = nbaseline+ncontrol+ncycle*(nactive+ncontrol);
    if isopcond
        ndeactive = 5; % 4; number of deactive scans
        vols = nbaseline+ncontrol+ndeactive+ncontrol+ncycle*(nactive+ncontrol+ndeactive+ncontrol)+ncontrol;
    end
    
    params.fb.emul = true; % false; using mouse position
    params.pulse.emul = true; % false; using timer
    sub = 'test';
else
    sub = sub{1};
end

if ~params.pulse.emul
    try
        daq = daqfind;
    catch
        clear global params;
        error('Data Acquisition Toolbox is not available!');
    end
    % pulse from the scanner
    if (~isempty(daqfind))
        stop(daqfind)
    end
    params.pulse.io = digitalio('parallel','LPT1');
    addline(params.pulse.io,10,'in');
end

params.file.roi = fullfile(trdir, 'roi_info.txt'); % roi_file
params.file.log = fullfile(fileparts(mfilename('fullpath')),[strrep(datestr(date,29),'-','') '_' sub '_report']); % log_file
while exist([params.file.log '.txt'],'file')
    params.file.log = [params.file.log '+'];
end
params.file.log = [params.file.log '.txt'];
params.file.logfid = fopen(params.file.log,'w');

% create reference
params.nbase = nbaseline;
params.ref = zeros(1,vols);
params.ref(1:nbaseline) = 99; nstart = nbaseline + ncontrol;
cycle = [ones(1,nactive) zeros(1,ncontrol)];
if ndeactive
    params.ref(nstart+1:nstart+ndeactive) = -1;
    nstart = nstart+ndeactive+ncontrol;
    cycle = [cycle -ones(1,ndeactive) zeros(1,ncontrol)];
end
lcycle = numel(cycle);
for i = 0:ncycle-1
    params.ref(nstart+(i*lcycle)+1:nstart+(i*lcycle)+lcycle) = cycle;
end

if isopcond
    params.com.txt = {'Count' 'Feedback' 'Think'}; % Deact Control Act
else
    params.com.txt = {'' 'Count' 'Think'}; % Deact Control Act
end
params.com.wait = 0.5; % sec

Screen('Preference', 'Verbosity', 1);
%Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','SyncTestSettings',0.005,50,0.1,5);
[params.w, params.r] = Screen(0,'OpenWindow',[],[0 0 1024 768]);
params.col=BlackIndex(params.w);
params.bg=WhiteIndex(params.w);
SetMouse(params.r(RectRight)/2,params.r(RectBottom));

[params.fb.obj.img scale] = load_images(fullfile(fileparts(mfilename('fullpath')),'Pics'),params.r,1);
fields = fieldnames(params.fb.obj.img);
params.fb.obj.img = params.fb.obj.img.(fields{2}){1};
x0 = params.r(RectRight)/2-size(params.fb.obj.img,2)/2;
y0 = params.r(RectBottom)/2-size(params.fb.obj.img,1)/2;
params.fb.range = 21;
params.fb.obj.Unit = UNIT;
params.fb.obj.Window = params.w;
params.fb.obj.WindowRect = [x0+53*scale y0+13*scale x0+160*scale y0+1215*scale];
params.fb.obj = FeedbackVertData(params.fb.obj,params.fb.range);

%logfile
fprintf(params.file.logfid,'Design: %d | %d | (%d,%d)\n\n', nbaseline, ncontrol, nactive, ncontrol);
fprintf(params.file.logfid,'Stimulus time: % 5.3d s\n\n', params.st_wait);
