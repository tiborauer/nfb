function model = mvpc_train(cfg)

[roi, bg] = roi_read(cfg);

data_train = data_read(cfg, roi, bg);
[ref_train, nb] = reference_read(cfg, 0);
[data_train, ref_train] = data_select(data_train, ref_train, cfg);
if cfg.Perc, data_train = perc_data(data_train, nb); end

if strcmp(cfg.Method, 'NN')
    model = train_bp(data_train, ref_train);
elseif strcmp(cfg.Method, 'SVM')
    model = svmlearn(data_train', ref_train', '-c 100 -v 0');
end