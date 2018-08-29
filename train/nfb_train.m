function [res fb fb0] = nfb_train(varargin)
fini = varargin{1};
name = varargin{2};
vol = varargin{3};
online = true;
run = true;
ask = true;
ind = 0;
trstr = '';
if nargin > 3, ind = cell_index({varargin{4:end}},'mode'); end
if ind
    mode = varargin{ind+4};
    % mode:
    %   online_ask (+run: default)
    %   online_noask (+run)
    %   offline_run (+noask)
    %   offline_norun (+noask)
    si = findstr(mode,'_');
    online = strcmp(mode(1:si-1),'online');
    if online
        run = true;
        ask = strcmp(mode(si+1:end),'ask');
    else
        ask = false;
        run = strcmp(mode(si+1:end),'run');
        if nargin > ind+4
            trstr = varargin{ind+5};
        else
            disp('Warning! Offline mode is set but no training specified! Last training will be analyzed.');
        end
    end
end
if nargin > 3, ind = cell_index({varargin{4:end}},'fit'); end
if ind
    hf = varargin{ind+4};
else
    hf = 0;
end

% read project
if ischar(fini)
    ini = IniFile(fini);
    if ~ini.isValid, return; end
else
    ini = fini;
    fini = ini.FileName;
end
idir = fileparts(fini);

isvol = false;
for cv = 1:ini.volunteers.nvol
    if strcmp(ini.volunteers.(['vol' num2str(cv)]),name)
        isvol = true;
        break;
    end
end
if ~isvol, error(sprintf('No volunteer %s found!',name)); end
meas = str2num(ini.volunteers.(['meas' num2str(cv)]));
if online
    if (meas(end) ~= vol) || (ini.series.base_st && (numel(meas) == 2) && ...
            exist(fullfile(ini.directories.traindir,['vol_' num2str(meas(end))],'l_base'),'dir') && ...
            exist(fullfile(ini.directories.traindir,['vol_' num2str(meas(end))],'r_base'),'dir'))
        meas(end+1) = vol;
        ini.volunteers.(['meas' num2str(cv)]) = num2str(meas);
    end
    nmeas = numel(meas) - 1 - ini.series.base_st;
    if nmeas == 13, nmeas = 0; end
    
    ini.Close;
else
    nmeas = find(meas==vol);
    if numel(nmeas)>1
        nmeas=nmeas(1+isempty(findstr(trstr,'base')));
    end
    if isempty(nmeas), error('Offline mode is set but no measurement %d found for %s!',vol,name); end
    nmeas = nmeas - 1 - ini.series.base_st;
end

% read rtconfig template
rtconfig  = IniFile(fullfile(nfb_dir, ini.files.rtfile));
if ~rtconfig.isValid
    error('rtconfig file not valid! Check NFB installation!');
end

% write new rtconfig
rtconfig.data.no_roi = ini.training.nroi;
w = str2num(ini.training.fb);
for i = 1:ini.training.nroi
    rtconfig = rtconfig.AddVariable('data',5+(i-1)*2+1,['targ_roi' num2str(i)],'s',...
        fullfile(ini.directories.traindir,['vol_' num2str(meas(1))],ini.directories.roidir,ini.training.(['roi' num2str(i)])));
    rtconfig = rtconfig.AddVariable('data',5+(i-1)*2+2,['w_roi' num2str(i)],'n',w(i));
end
if ~isempty(ini.training.roibg)
    rtconfig.data.bg_roi = fullfile(ini.directories.traindir,['vol_' num2str(meas(1))],ini.directories.roidir,ini.training.roibg);
end
if online
    cdir = fullfile(ini.directories.traindir,['vol_' num2str(meas(end))]);
else
    cdir = isInDB(fullfile(ini.directories.traindir,['vol_' num2str(meas(nmeas+1+ini.series.base_st))]));
end
if online || isempty(trstr)
    TrAll = lower(unique(ini.training.m0));
    nTrAll = zeros(1,numel(TrAll));
    for m = 0:nmeas-1
        Tr = lower(ini.training.(['m' num2str(m)]));
        for t = 1:numel(TrAll)
            nTrAll(t) = nTrAll(t)+ numel(strfind(Tr,TrAll(t)));
        end
    end
    Tr = lower(ini.training.(['m' num2str(nmeas)]));
    for t = 1:numel(Tr)
        if isempty(m)
            trstr = sprintf('%s_base',Tr(t));
        else
            nTrAll(strfind(TrAll,Tr(t))) = nTrAll(strfind(TrAll,Tr(t)))+1;
            trstr = sprintf('%s_tr%d',Tr(t),nTrAll(strfind(TrAll,Tr(t)))-1);
        end
        TrDir=fullfile(cdir,trstr);
        if ~exist(TrDir,'dir'), break; end
    end
    if online && exist(TrDir,'dir')
        error('Every training for this measurement is already done!');
    end
end
if online
    rtconfig.data.watch_dir = ini.directories.watchdir;
    rtconfig.data.tr_dir = '';
    rtconfig.data.outfile = ini.files.outfile;
else
    TrDir=isInDB(fullfile(cdir,trstr));
    if ~exist(TrDir,'dir')
        error('No training %s exists within measurement %d for %s!',trstr,vol,name);
    end
    rtconfig.data.watch_dir = TrDir;
    rtconfig.data.tr_dir = 'none';
    rtconfig.data.outfile = '';
end
rtconfig.data.output_dir = fullfile(cdir,[trstr '_out']);

rtconfig.preprocess.moco_ref = fullfile(ini.directories.traindir,['vol_' num2str(meas(1))],ini.directories.locdir,'loc_001.nii');

% go
text = sprintf('%d. measurement.\nNext experiment: %s.',nmeas,upper(trstr));
if ask
    selection = questdlg(sprintf('%s\nPress OK to continue!',text),'Check settings!','OK','Cancel','OK');
    run = run & strcmp(selection,'OK');
else
    disp(text);
end

fb0 = 0;
if run
    if ~online && exist([fullfile(cdir,trstr) '_out'],'dir')
        pfx = '';
        while exist([fullfile(cdir,trstr) '_out_old' pfx],'dir')
            pfx = [pfx '+'];
        end
        movefile([fullfile(cdir,trstr) '_out'],[fullfile(cdir,trstr) '_out_old' pfx]);
        if exist(fullfile(cdir,[trstr '_out_old'], 'ROI_Measured', 'results.mat'),'file')
            load(fullfile(cdir,[trstr '_out_old'], 'ROI_Measured', 'results.mat'));
            fb0 = result.ts(:,10);
        end
    end
    nfb_main(rtconfig);
    close all hidden;
else
    rtconfig.Close(fullfile(idir,[name '_' num2str(vol) '_rt.txt']));
end

% create results
if online
    rois = dir(fullfile(rtconfig.data.output_dir,'ROI*'));
    for i = 1:numel(rois)
        load(fullfile(rtconfig.data.output_dir,rois(i).name,'results.mat'));
        res(:,i) = cell2mat({result.inferential.target_GLM{:,2}})';
    end
else
    res = roi_glm_batch(fini,vol,trstr,hf);
end
load(isInDB(fullfile(cdir,[trstr '_out'], 'ROI_Measured', 'results.mat')));
fb = result.ts(:,10);