function [dataout refout] = data_select(datain, refin, cfg)
s = warning('off', 'MATLAB:conversionToLogical');
for i = 1:size(datain, 1)
    dataout(i,:) = datain(i,logical(refin));
end
refout = refin(logical(refin));
if strcmp(cfg.Method, 'NN')
    refout = (refout+1)/2;
end
warning(s);