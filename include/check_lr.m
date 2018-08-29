function res = check_lr(fname) 
% lr 
%     '1' - R
%     '0'
%
%     '0'
%     '1' - L

ptrnR = { 
    'Right'
    '_r'
    };
ptrnL = {
    'Left'
    '_l'
    };

a = logical(spm_read_vols(spm_vol(fname)));
r = sum(sum(sum(a(1:size(a,1)/2,:,:)))); % R
l = sum(sum(sum(a(size(a,1)/2+1:size(a,1),:,:)))); % L

if strcfind(fname,ptrnL)
    res = (l > r)*2-1;
elseif strcfind(fname,ptrnR)
    res = (r > l)*2-1;
else
    res = 0;
end
end