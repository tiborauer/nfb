function [err, msg] = nfb_sanity_reference(rtconfig)
err = 0;
msg = {};

[ref, san] = nfb_reference(rtconfig);
if san < 0
    msg{end+1} = sprintf('ERROR! Model is not long enough!\nVolumes for analysis: %d\tVolumes in reference file: %d\n',...
        rtconfig.timing.volumes, length(ref.vec.fb));
    fprintf(msg{end});
    err = max(err,2);    
elseif san > 0
    msg{end+1} = sprintf('WARNING! Model is longer then the acquisition!\nVolumes for analysis: %d\tVolumes in reference file: %d\n',...
        rtconfig.timing.volumes, length(ref.vec.fb));
    fprintf(msg{end});
    err = max(err,1);    
end

if ~sum(~isnan(ref.vec.fb))
	msg{end+1} = sprintf('ERROR! Paradigm invalid. There is no feedback presented at all. Please revise!\n');
	fprintf(msg{end});
	err = max(err,2);    
end
