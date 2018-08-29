function out = check_roi_lr(fini,vol)
ini = IniFile(fini);
if ~ini.isValid, return; end

for i = 1:ini.training.nroi
    fprintf('Checking LR orientation...');
    out(i) = check_lr(fullfile(ini.directories.traindir,['vol_' num2str(vol)],ini.directories.roidir,[ini.training.(['roi' num2str(i)]) '.nii.gz']));
    switch rtconfig.data.flip_lr(i)
        case -1
            fprintf('Incorrect!\n');
        case 1
            fprintf('Correct!\n');
        otherwise
            fprintf('Not interpretable!\n');
    end
end

out = sum(out) < 0;
if out
    fprintf('WARNING: L/R Flip will be applied on ROIs!\n');
end







