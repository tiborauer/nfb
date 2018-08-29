function stat = nfb_rename(fini)
ini = IniFile(fini);
if ~ini.isValid, return; end
stat = 0; dcheck = true;  s = 2; v = 5; t = 4;
for s = 1:ini.volunteers.nvol
    csubj = ini.volunteers.(['vol' num2str(s)]);
    cmeas = str2num(ini.volunteers.(['meas' num2str(s)]));
    for v = 1:numel(cmeas)-1
        vdir = fullfile(ini.directories.traindir,['vol_' num2str(cmeas(v+1))]);
        d = dir(fullfile(vdir,'*tr*_out'));
        if (ini.series.base_st && (v == 1)) ||...
                (ini.series.base_end && (v == (ini.series.base_st+ini.training.nm+1)))...
                d = dir(fullfile(vdir,'*base_out'));
        end
        for t = 1:numel(d)            
            d1 = fullfile(vdir,d(t).name);
            dn = [d1 '_new'];
            d2 = d(t).name;
            do = [d2 '_old'];
            if exist(dn,'dir')
                stat = stat + rename(d1,do);
                stat = stat + rename(dn,d2);
            else
                disp(dn);
                dcheck = false;
            end
        end
    end
end
if dcheck, disp('Every directory exist!'); end