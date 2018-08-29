function [hrf r p] = hrf_fit(data,des)
onset = [find(diff(des)==1)+1; numel(data)];
hrf = zeros(onset(1)-6,1);
for i = 1:numel(onset)-1
    datai = data(onset(i)-5:onset(i+1)-6);
    desi = des(onset(i)-5:onset(i+1)-6);
    ip = fmincon(@(x)hrf_cost(x,datai,desi),[6 16 1 1 6 32],[],[],[],[],[1 2 1 1 1 4],[],@hrf_constr,optimset('Algorithm','interior-point'));
    r(i) = hrf_cost(ip,data,des);
    p(i,:) = [ip(1) ip(2) ip(3) ip(4) ip(5) 0 ip(6)];
    h = spm_bfhrf(desi, 22, 1, 2, p(i,:));
    hrf = [hrf; h];
end
hrf = [hrf; zeros(6,1)];
