function rtconfig = nfb_open(rtconfig)

fprintf('\n\nWelcome! This is nfb-toolbox version %s\n',nfb_ver);

fprintf('Started on %s\n\n', datestr(clock));

clear global params; % cleanup in case of a previos break-down
global params CANCEL PAUSE NFB_ROOTDIR NFB_VER ROI ROI_CHNG;

ROI_CHNG = false;
NFB_VER = nfb_ver;
CANCEL = 0;
PAUSE = 0;
ROI = []; % weights of rois e.g.: '0010' -> we have 4 rois and 3rd id selected

params.clocks.rt = clock;

NFB_ROOTDIR = nfb_dir;
params.path.nfb_rootdir = NFB_ROOTDIR;

params.path.start_dir = pwd;
params.path.req{1} = params.path.nfb_rootdir;
params.path.req{2} = fullfile(params.path.nfb_rootdir, 'include');
run(fullfile(params.path.nfb_rootdir, 'include','path_add'));
params.path.req{3} = fullfile(params.path.nfb_rootdir, 'include', 'net_data');
params.path.req{4} = fullfile(params.path.nfb_rootdir, 'include', 'net_data', 'tcpudpip');
params.path.req{5} = fullfile(params.path.nfb_rootdir, 'include', 'spm_realign');
params.path.req{6} = fullfile(params.path.nfb_rootdir, 'include', 'spm_realign', 'spm');
params.path.req{7} = fullfile(params.path.nfb_rootdir, 'include', 'roi');
params.path.req{8} = fullfile(params.path.nfb_rootdir, 'gui');
params.path.req{9} = fullfile(params.path.nfb_rootdir, 'presentation');
params.path.req = horzcat(params.path.req, genpath_cell(fullfile(params.path.nfb_rootdir,'include','mvpc')));
path_add;

p = pwd;
if ~nargin
    rtconfig = '';
    d = dir('*rtconfig*');
    if ~isempty(d), rtconfig = fullfile(p, d(1).name); end
end

if ischar(rtconfig) % filename
    if exist(rtconfig,'file')
        if isempty(fileparts(rtconfig)), rtconfig = fullfile(p, rtconfig); end
    else
        [FileName, Path] = uigetfile(...
            {'*.ini;*.txt','Config (*.ini,*.txt)';...
            '*.*','All Files (*.*)'},...
            'Please select a configuration file',pwd);
        rtconfig = fullfile(Path,FileName);
    end
    rtconfig = IniFile(rtconfig);
end

if ~rtconfig.isValid, rtconfig = []; return; end

if ~isempty(rtconfig.data.output_dir) && ~exist(rtconfig.data.output_dir,'dir'), mkdir(rtconfig.data.output_dir); end
params.files.logfile = fullfile(rtconfig.data.output_dir,'report.log');
fid = fopen(params.files.logfile,'w');
fclose(fid);
diary off
diary(params.files.logfile);

if strcmp(rtconfig.data.watch_dir,'net')
    params.data.watch.sock = pnet('tcpsocket',2100);
    if (params.data.watch.sock == -1)
        nfb_close('Specified TCP port is not possible to use now.');
        return
    end
    pnet(params.data.watch.sock,'setreadtimeout',rtconfig.timing.timeout);
    fprintf('Waiting for connection...\n');
    params.data.watch.con = pnet(params.data.watch.sock,'tcplisten');
    if (params.data.watch.con == -1)
        nfb_close('Connection is not possible to use now.');
        return
    end
    pnet(params.data.watch.con,'setreadtimeout',rtconfig.timing.timeout);  % Wait for data
else
    params.data.watch = rtconfig.data.watch_dir;
end

if ~isnan(str2double(rtconfig.data.outfile(1))) % UDP    
    port = 5678;
    udp = pnet('udpsocket',port);
    if udp == -1, fprintf('UDP port %d cannot open\n',port); 
    else fprintf('UDP port %d is open!\n',port); end
    params.data.out.host = rtconfig.data.outfile;
    params.data.out.port = port;
    params.data.out.udp = udp;
    rtconfig.data.outfile = 'net';
end

% CBSU
opengl software;

end