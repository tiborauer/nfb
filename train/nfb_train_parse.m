function fini = nfb_train_parse(fini)
ini = IniFile(fini);
if ~ini.isValid, return; end
ch = false;
if exist(fullfile(ini.directories.resdir,ini.files.resfile),'file')
    load(fullfile(ini.directories.resdir,ini.files.resfile));
    ch = true;
end
dcheck = 0; vdel = 0; s = 2; v = 5; t = 4;
for s = 1:ini.volunteers.nvol
    csubj = ini.volunteers.(['vol' num2str(s)]);
    cmeas = str2num(ini.volunteers.(['meas' num2str(s)]));
    comm = ini.getComment('volunteers',['vol' num2str(s)]);
    ini = ini.RemoveVariable('volunteers',['vol' num2str(s)]);
    ini = ini.RemoveVariable('volunteers',['meas' num2str(s)]);
    vOK = true;
    for v = 1:numel(cmeas)-1
        try
            vdir = isInDB(fullfile(ini.directories.traindir,['vol_' num2str(cmeas(v+1))]));
        catch
            vOK = false;
            dcheck = dcheck + 1;
            fprintf('Directory %s for %s does not exist!\n',['vol_' num2str(cmeas(v+1))],csubj);
            continue;
        end
        d = dir(fullfile(vdir,'*tr*_out'));
        if (ini.series.base_st && (v == 1)) ||...
                (ini.series.base_end && (v == (ini.series.base_st+ini.training.nm+1)))...
                d = dir(fullfile(vdir,'*base_out'));
        end
        for t = 1:numel(d)
            tdir = strrep(d(t).name,'_out','');
            if ch && (s <= size(meas,1)) && (v <= size(meas,2)) && strcmp(meas{s,v,t},[csubj,num2str(cmeas(v+1)),tdir])
                continue;
            end
            if ~exist(fullfile(vdir,tdir),'dir')
                dcheck = dcheck + 1;
                fprintf('Directory %s in %s does not exist!\n',tdir,vdir);
            end
        end
    end
    vdel = vdel + ~vOK;
    if vOK
        ini = ini.AddVariable('volunteers',1+(s-vdel-1)*2+1,['vol' num2str(s-vdel)],'s',csubj,comm);
        ini = ini.AddVariable('volunteers',1+(s-vdel-1)*2+2,['meas' num2str(s-vdel)],'s',num2str(cmeas));
    end
end
if vdel
    fini = strrep(fini,'.ini','_c.ini');
    ini.volunteers.nvol = ini.volunteers.nvol - vdel;
    ini.Close(fini);
end
if ~dcheck
    disp('Every directory exist!');
else
    fprintf('%d directories do not exist!\n',dcheck);
end