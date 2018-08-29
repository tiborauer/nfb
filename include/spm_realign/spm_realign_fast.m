function [v, P2] = spm_realign_fast(in,par)

if ischar(in)
    switch in(end-2:end)
        case {'hdr' 'img' 'nii'}
            P2 = spm_vol(in);
        case 'dcm'
            P2 = dicom_hdr(in); 
            P2.dim = P2.Dimensions;
            P2.dat = dicom_img(in);
    end
    
else
    P2 = in;
    P2.dim = size(in.dat);
end

flags = par.flags;

flags.write = par.write;
flags.mask = 1;

mat1 = par.mat1;
A0 = par.A0;
b = par.b;
x1 = par.x1;
x2 = par.x2;
x3 = par.x3;
deg = par.deg;
lkp = par.flags.lkp;

% -----------------------------------------------------------------------
V  = smooth_vol(P2,flags.interp,flags.fwhm);
d  = [size(V) 1 1];
d  = d(1:3);
ss = Inf;
countdown = -1;
for iter=1:128
	[y1,y2,y3] = coords([0 0 0  0 0 0],mat1,P2.mat,x1,x2,x3);
	msk        = find((y1>=1 & y1<=d(1) & y2>=1 & y2<=d(2) & y3>=1 & y3<=d(3)));
	if length(msk)<32, error('ErrorTests:convertTest','There is not enough overlaping voxels.\nCheck orinetation!'); end;
	F          = spm_bsplins(V, y1(msk),y2(msk),y3(msk),deg);
	A          = A0(msk,:);
	b1         = b(msk);
	sc         = sum(b1)/sum(F);
	b1         = b1-F*sc;
	soln       = (A'*A)\(A'*b1);
 	p          = [0 0 0  0 0 0  1 1 1  0 0 0];
	p(lkp)     = p(lkp) + soln';
	P2.mat     = spm_matrix(p)\P2.mat;
	pss        = ss;
	ss         = sum(b1.^2)/length(b1);
	if (pss-ss)/pss < 1e-8 && countdown == -1, % Stopped converging.
		countdown = 2;
	end;
	if countdown ~= -1,
		if countdown==0, break; end;
		countdown = countdown -1;
	end;
end;

%if flags.write
 %   spm_get_space([P2.fname ',' num2str(P2.n)], P2.mat);
%end

if flags.mask
	x1    = repmat((1:P2.dim(1))',1,P2.dim(2));
	x2    = repmat( 1:P2.dim(2)  ,P2.dim(1),1);
	if flags.mask, msk = cell(P2.dim(3),1);  end;
	for x3 = 1:P2.dim(3),
    	tmp = zeros(P2.dim(1:2)) + getmask(inv(mat1\mat1),x1,x2,x3) + getmask(inv(mat1\P2.mat),x1,x2,x3);
		if flags.mask, msk{x3} = find(tmp ~= 2); end;
	end;
end;

[x1,x2] = ndgrid(1:P2.dim(1),1:P2.dim(2));
d     = [flags.interp*[1 1 1]' [0 0 0]'];
if isfield(P2,'fname')
    C  = spm_bsplinc(P2,d);
elseif isfield(P2,'dat')
    C  = spm_bsplinc(P2.dat,d);
end
v = zeros(P2.dim);
for x3 = 1:P2.dim(3),
    [tmp,y1,y2,y3] = getmask(inv(mat1\P2.mat),x1,x2,x3);
   	v(:,:,x3)      = spm_bsplins(C, y1,y2,y3, d);

	if flags.mask, tmp = v(:,:,x3); tmp(msk{x3}) = NaN; v(:,:,x3) = tmp; end;
end;
% if flags.write
%     VO         = P2;
%     VO.fname   = prepend(P2.fname,'r');
%     VO.dim     = P2.dim(1:3);
%     VO.dt      = P2.dt;
%     V0.pinfo   = P2.pinfo;
%     VO.mat     = mat1;
%     VO.descrip = 'spm - realigned';
%     VO = spm_write_vol(VO,v);
%     for x3 = 1:P2.dim(3),
%       v(:,:,x3) = v(:,:,x3)';
%     end;
% end

v = fill_nan(v);

return;
%_______________________________________________________________________

%_______________________________________________________________________
function [y1,y2,y3]=coords(p,M1,M2,x1,x2,x3)
% Rigid body transformation of a set of coordinates.
% M  = (inv(M2)*inv(spm_matrix(p))*M1);
M  = M2\(spm_matrix(p)\M1);
y1 = M(1,1)*x1 + M(1,2)*x2 + M(1,3)*x3 + M(1,4);
y2 = M(2,1)*x1 + M(2,2)*x2 + M(2,3)*x3 + M(2,4);
y3 = M(3,1)*x1 + M(3,2)*x2 + M(3,3)*x3 + M(3,4);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function V = smooth_vol(P,hld,fwhm)
% Convolve the volume in memory.
s  = sqrt(sum(P.mat(1:3,1:3).^2)).^(-1)*(fwhm/sqrt(8*log(2)));
x  = round(6*s(1)); x = -x:x;
y  = round(6*s(2)); y = -y:y;
z  = round(6*s(3)); z = -z:z;
x  = exp(-(x).^2/(2*(s(1)).^2));
y  = exp(-(y).^2/(2*(s(2)).^2));
z  = exp(-(z).^2/(2*(s(3)).^2));
x  = x/sum(x);
y  = y/sum(y);
z  = z/sum(z);

i  = (length(x) - 1)/2;
j  = (length(y) - 1)/2;
k  = (length(z) - 1)/2;
d  = [hld*[1 1 1]' [0 0 0]'];
if isfield(P,'fname')
    V  = spm_bsplinc(P,d);
elseif isfield(P,'dat')
    V  = spm_bsplinc(P.dat,d);
end
spm_conv_vol(V,V,x,y,z,-[i j k]);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [Mask,y1,y2,y3] = getmask(M,x1,x2,x3)
y1   = M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
y2   = M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
y3   = M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));
Mask = true(size(y1));
return;
%_______________________________________________________________________

%_______________________________________________________________________
function PO = prepend(PI,pre)
[pth,nm,xt,vr] = fileparts(deblank(PI));
PO             = fullfile(pth,[pre nm xt vr]);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function r = fill_nan(a)
r = a;
r(find(isnan(a))) = 0;
return
