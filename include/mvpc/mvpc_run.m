function [fn t ref_test] = mvpc_run(fn)

load(fullfile('/nmr/siemens/users/tauer/vol_4728/results/RealTimeData',fn));

cfg = mvpc.cfg;
cfg.Path2Test = '/nmr/siemens/users/tauer/vol_4728/results/RealTimeData/nfb_data';
cfg.RefFile_Test = '/nmr/siemens/users/tauer/vol_4728/results/RealTimeData/nfb_out/reference.txt';
model = mvpc.model;

[roi, bg] = roi_read(cfg);

data_test = data_read(cfg, roi, bg);
[ref_test, nb] = reference_read(cfg, 1);
[data_test, ref_test] = data_select(data_test, ref_test, cfg);
if cfg.Perc, data_test = double(perc_data(data_test, nb)); end

if strcmp(cfg.Method, 'NN')
    t = sim(model.net, data_test);
    t = t(end,:);
elseif strcmp(cfg.Method, 'SVM')
    [e, t] = svmclassify(data_test', ref_test', model);
    t = detrend(t);
end

if cfg.Perc
    fn = [cfg.Method '_' strrep(num2str(cfg.ROI),'  ',' ') '_Shift' num2str(cfg.ShiftRef) '_Perc'];
else
    fn = [cfg.Method '_' strrep(num2str(cfg.ROI),'  ',' ') '_Shift' num2str(cfg.ShiftRef) '_Raw'];
end
if ~nargout
    figure(1)
    plot(t)
    hold on
    plot(ref_test, 'r');
    saveas(1,[fn '.tif']);
end