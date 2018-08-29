function nfb_reanalyzer(study, vol, tr)
TrDIR = sprintf('Z:\\siemens\\%s\\vol_%d\\results\\RealTimeData',study,vol);
d = dir(TrDIR);
isfound = false;
for i = 3:numel(d)
	if ~tr
		if strfind(d(i).name,'base_out')
			isfound = true;
			break;
		end
	else
		if strfind(d(i).name,sprintf('tr%d_out',tr))
			isfound = true;
			break;
		end
	end
end
if ~isfound, error(sprintf('%d. training not found in %s',tr, TrDIR)); end
TrDIR = fullfile(TrDIR,d(i).name);
d = dir(fullfile(TrDIR,'ROI_*'));
for i = 1:numel(d)
    nfb_analyzer('offline',fullfile(TrDIR,d(i).name,'results.mat'),3,fullfile(TrDIR,d(i).name));
end