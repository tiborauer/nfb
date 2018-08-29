function data = data_read(cfg, roi, bg, n)
if isfield(cfg,'Path2Test')
    path = cfg.Path2Test;
else
    path = cfg.Path2Train;
end
sd = pwd;
cd(path);
d = dir(fullfile(path, '*.img'));
if nargin < 4
    n = numel(d);
end

if ischar(roi)
    inf = spm_vol(fullfile(path, d(1).name));
    roi = true(inf.dim);
end

data_bg = [];
h = waitbar(0, 'Reading files...');
for i = 1:n
    a = spm_read_vols(spm_vol(fullfile(path, d(i).name)));
    if cfg.Bg, data_bg = double(a(bg)); end
    switch cfg.Bg
        case 0
            data(:,i) = double(a(roi));
        case 1
            data(:,i) = double(a(roi))-mean(data_bg);
        case 2
            data(:,i) = [double(a(roi)); data_bg];
    end
    waitbar(i/n, h);
end
close(h);

if ischar(roi)
    if strcmp(roi, 'mask')
        mask = mask_int(data(:,1));
    elseif strcmp(roi, 'mask+')
        mask = mask_int(data(:,1)).*mask_std(data(:,1:30));
    end
    for i = 1:n
        data(:,i) = data(mask,i);
    end
end
cd(sd);