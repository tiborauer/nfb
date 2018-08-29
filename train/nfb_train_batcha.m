function nfb_train_batcha(fini)
pfx = {'_nofit.mat'};% '_delayfit.mat'};
fini = nfb_train_parse(fini);
ini = IniFile(fini);
rf0 = ini.files.resfile;
for i = 0:numel(pfx)-1
    ini.files.resfile = strrep(rf0,'.mat',pfx{i+1});
    nfb_train_analyze(ini,false,i);
    nfb_train_plot(ini,2);
end
