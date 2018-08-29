function [meas res] = nfb_train_analyze_loc(varargin)
fini = varargin{1};
rerun = varargin{2};
if nargin == 3
    hf = varargin{3};
else
    hf = 0;
end
if ischar(fini)
    ini = IniFile(fini);
    if ~ini.isValid, return; end
else
    ini = fini;
end
res_file = fullfile(ini.directories.resdir,strrep(ini.files.resfile,'.mat','_loc.mat'));
if exist(res_file,'file')
    load(res_file);
end
dcheck = {}; 
for s = 1:ini.volunteers.nvol
    csubj = ini.volunteers.(['vol' num2str(s)]);
    cmeas = str2num(ini.volunteers.(['meas' num2str(s)]));
    cmeas = cmeas([1 1+ini.series.base_st+ini.training.nm+ini.series.base_end:end]);
    for v = 1:numel(cmeas)
        vdir = isInDB(fullfile(ini.directories.traindir,['vol_' num2str(cmeas(v))]));
        if isempty(vdir)
            fprintf('Directory %s for %s does not exist!',['vol_' num2str(cmeas(v))],csubj);
            continue;
        end
        if exist(isInDB(fullfile(vdir,'loc')),'dir')
            pfx = '';
            if ~rerun, pfx = 'no'; end
            meas{s,v} = [csubj,num2str(cmeas(v)),'loc'];
            res{s,v} = nfb_train(fini,csubj,cmeas(v),'mode',['offline_' pfx 'run'],'loc','fit',hf);
            delete *rt.txt;
        else
            dcheck{end+1} = fullfile(vdir,tdir);
            fprintf('Directory %s not found!\n',dcheck{end});
        end
        if rerun || (hf == 2)
            save(res_file,'meas','res');
        end
    end
end
if isempty(dcheck)
    disp('Every directory exist!');
else
    for i = 1:numel(dcheck)
        fprintf('Directory %s not found!\n',dcheck{i});
    end
end
save(res_file,'meas','res')