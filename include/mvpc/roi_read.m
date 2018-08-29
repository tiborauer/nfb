function [roi, bg] = roi_read(cfg)
sd = pwd;
cd(cfg.Path2Train);
info = spm_vol('Analyze00001.img');
dim = info.dim;
bg = logical(nfb_roi2analyze(cfg.Path2Roi{end}, dim, false));
if ischar(cfg.ROI)
    roi = cfg.ROI;
else
    roi = false(dim(1:3));
    for i = 1:numel(cfg.Path2Roi)-1
        if cfg.ROI(i)
            roi = roi | logical(nfb_roi2analyze(cfg.Path2Roi{i}, dim, false));
        end
    end
end
if ~cfg.Bg, bg = 0; end
cd(sd);