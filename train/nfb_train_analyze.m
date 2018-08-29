function [meas res fb fb0] = nfb_train_analyze(varargin)
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
ch = false;
if exist(fullfile(ini.directories.resdir,ini.files.resfile),'file')
    load(fullfile(ini.directories.resdir,ini.files.resfile));
    ch = true;
end
dcheck = {};  s = 22; v = 3; t = 1;
nc = ini.volunteers.nvol - ini.volunteers.nTr;
for s = 1:ini.volunteers.nvol
    csubj = ini.volunteers.(['vol' num2str(s)]);
    cmeas = str2num(ini.volunteers.(['meas' num2str(s)]));
    for v = 1:numel(cmeas)-1
        vdir = isInDB(fullfile(ini.directories.traindir,['vol_' num2str(cmeas(v+1))]),2);
        if isempty(vdir)
            fprintf('Directory %s for %s does not exist!',['vol_' num2str(cmeas(v+1))],csubj);
            continue;
        end
        %d = dir(fullfile(vdir,'*tr*_out'));
        if (s <= nc) && isin(v,2,numel(cmeas)-2)
            d = [];                
        else
            task = unique(lower(ini.training.m1));
            for t = 1:numel(task)
                rep = numel(find(task(t)==lower(ini.training.m1)));
                for r = 1:rep
                    d((t-1)*rep+r).name = [task(t) '_tr' num2str((v-2)*rep+r) '_out'];
                end
            end
        end
        if (ini.series.base_st && (v == 1)) ||...
                (ini.series.base_end && (v == (ini.series.base_st+ini.training.nm+1))) ||...
                (v > (ini.series.base_st+ini.training.nm+ini.series.base_end))...
                d = dir(fullfile(vdir,'*base_out'));
        end
        for t = 1:numel(d)
            tdir = strrep(d(t).name,'_out','');
            if ch && (s <= size(meas,1)) && (v <= size(meas,2)) && strcmp(meas{s,v,t},[csubj,num2str(cmeas(v+1)),tdir])
                continue;
            end
            if ~isempty(isInDB(fullfile(vdir,tdir)))
                pfx = '';
                if ~rerun, pfx = 'no'; end
                [cres fb{s,v,t} fb0{s,v,t}] = nfb_train(fini,csubj,cmeas(v+1),'mode',['offline_' pfx 'run'],tdir,'fit',hf);
				res{s,v,t} = cres{1};
				if numel(cres) > 1, res_fb{s,v,t} = cres{2}; end
                delete *rt.txt;
            else
                dcheck{end+1} = fullfile(vdir,tdir);
                fprintf('Directory %s not found!\n',dcheck{end});
            end
            meas{s,v,t} = [csubj,num2str(cmeas(v+1)),tdir];
            if rerun || (hf == 2)
                save(fullfile(ini.directories.resdir,ini.files.resfile),'meas','res','fb0','fb')
				if exist('res_fb','var'), save(fullfile(ini.directories.resdir,ini.files.resfile),'res_fb','-append'); end
            end
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
save(fullfile(ini.directories.resdir,ini.files.resfile),'meas','res','fb0','fb');
if exist('res_fb','var'), save(fullfile(ini.directories.resdir,ini.files.resfile),'res_fb','-append'); end