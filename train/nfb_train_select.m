function [meas_c res_c] = nfb_train_select(fini)
if ischar(fini)
    ini = IniFile(fini);
    if ~ini.isValid, return; end
else
    ini = fini;
end
if exist(fullfile(ini.directories.resdir,ini.files.resfile),'file')
    load(fullfile(ini.directories.resdir,ini.files.resfile));
else
    error('Results file not found!');
end

nsubj = 0;
for s = 1:ini.volunteers.nvol
    csubj = ini.volunteers.(['vol' num2str(s)]);
    for m = 1:size(meas,1)
        if findstr(meas{m,1,1},csubj)
            nsubj = nsubj +1;  
            for y = 1:size(meas,2)
                for z =  1:size(meas,3)
                    res_c{nsubj,y,z} = res{m,y,z};
                    meas_c{nsubj,y,z} = meas{m,y,z};
                end
            end
        end
    end
end
end