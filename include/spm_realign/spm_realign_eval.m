function r = spm_realign_eval(par,P2,v,img)
qq = spm_imatrix(P2.mat/par.mat1);
r = qq(1:6);
r(7) = sqrt(sum(r.^2));

if img
    figure(1)
    if isfield(P2,'fname')
        a1 = spm_read_vols(P2);
    elseif isfield(P2,'dat')
        a1 = P2.dat;
    end
    moco_diff = v-a1;
    for i = 1:size(moco_diff,3)
        md4(:,:,1,i) = histc_ad_2D(moco_diff(:,:,i),64,256);
    end
    montage(md4,colormap(gray(256)))
    saveas(1,'MoCo_registered-source.tif');
    figure(2)
    a0 = par.dat;
    moco_diff = v-a0;
    for i = 1:size(moco_diff,3)
        md4(:,:,1,i) = histc_ad_2D(moco_diff(:,:,i),64,256);
    end
    montage(md4,colormap(gray(256)))
    saveas(2,'MoCo_registered-target.tif');
end
return

function p = histc_ad_2D(r, l, u, m)
if nargin < 4
    m = (r ~= 0);
end
rd = r.*(r<0);
ra = r.*(r>0);

lr = min(rd(m));
ur = max(rd(m));
dr = ur-lr;
dp = (u-l)/2;
cr = double(dp)/double(dr);
prd = ((rd-lr)*cr+l).*m;

lr = min(ra(m));
ur = max(ra(m));
dr = ur-lr;
dp = (u-l)/2;
cr = double(dp)/double(dr);
pra = ((ra-lr)*cr).*m;

p0 = r.*~m;
p = p0 + prd + pra;
return
