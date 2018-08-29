function par_length = nfb_parest(ref)
% estimate the length (in volumes) of fMRI paradigm vector
% the reslut will be the length of the WHOLE cycle
%   if there is only activation OR deactivation -> act+cont OR deact+cont
%   if there are activation AND deactivation -> act+cont+deact+cont
%
% this file written by 
% Henry Luetcke (hluetck@gwdg.de) and
% Tibor Auer (tauer@gwdg.de)

vals = unique(ref);
for iv = 1:numel(vals)
    indv = find(ref == vals(iv));
    for ir = 1:numel(indv)
        for i = indv(ir)+1:numel(ref)
            if (ref(i) == vals(iv)) && (ref(i-1) ~= vals(iv)), break; end
        end
        if ~isempty(i)
            dist(ir) = i - indv(ir);
        end
    end
    par_length(iv) = max(dist);
end
par_length = max(par_length);
% e.o.f.