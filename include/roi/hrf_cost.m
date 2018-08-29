function n = hrf_cost(ip,data,des)
p = [ip(1) ip(2) ip(3) ip(4) ip(5) 0 ip(6)];
h = spm_bfhrf(des, 22, 1, 2, p);  
X=[h ones(numel(h),1)];
b=X\data;
n = norm(data-X*b);