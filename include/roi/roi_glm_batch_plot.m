function res = roi_glm_batch_plot(ini,vol,tr,hf)
if nargin < 4, hf = 1; end
ini = IniFile(ini);
if ~ini.isValid, error; end
w = str2num(ini.training.fb); w0 = find(w==0);
R = {ini.training.(['roi' num2str(find(w>0))]) ini.training.(['roi' num2str(find(w<0))]) 'Measured'};
for i = 1:numel(w0)
    R{end+1} = ini.training.(['roi' num2str(w0(i))]);
end
d = fullfile(ini.directories.traindir,['vol_' num2str(vol)],[tr '_out']);
for i = 1:numel(R)
    out = roi_glm(fullfile(d,['ROI_' R{i}],'results.mat'),fullfile(d,'reference.txt'),'fit',hf,'plot',1);
    res(1,i) = out.stat.delay;
    res(2,i) = out.stat.beta;
    res(3,i) = out.stat.t;
    res(4,i) = out.stat.PSC;
end