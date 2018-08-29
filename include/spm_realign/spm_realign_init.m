function par = spm_realign_init(in)

if ischar(in)
    P1 = spm_vol(in);
    par.dat = spm_read_vols(P1);
else
    P1 = in;
    P1.dim = size(P1.dat);
    par.dat = P1.dat;
end

flags = struct('fwhm',5,'sep',6,'interp',2,'lkp',1:6);

skip = sqrt(sum(P1.mat(1:3,1:3).^2)).^(-1)*flags.sep;
d    = P1.dim(1:3);                                                                                                                        
lkp = flags.lkp;
rand('state',0); % want the results to be consistant.
if d(3) < 3,
	lkp = [1 2 6];
	[x1,x2,x3] = ndgrid(1:skip(1):d(1)-.5, 1:skip(2):d(2)-.5, 1:skip(3):d(3));
	x1   = x1 + rand(size(x1))*0.5;
	x2   = x2 + rand(size(x2))*0.5;
else
	[x1,x2,x3] = ndgrid(1:skip(1):d(1)-.5, 1:skip(2):d(2)-.5, 1:skip(3):d(3)-.5);
	x1   = x1 + rand(size(x1))*0.5;
	x2   = x2 + rand(size(x2))*0.5;
	x3   = x3 + rand(size(x3))*0.5; 
end;

x1   = x1(:);
x2   = x2(:);
x3   = x3(:);

% Compute rate of change of chi2 w.r.t changes in parameters (matrix A)
%-----------------------------------------------------------------------
V   = smooth_vol(P1,flags.interp,flags.fwhm);
deg = [flags.interp*[1 1 1]' [0 0 0]'];

[G,dG1,dG2,dG3] = spm_bsplins(V,x1,x2,x3,deg);
clear V
A0 = make_A(P1.mat,x1,x2,x3,dG1,dG2,dG3,lkp);

par.b  = G;
par.mat1 = P1.mat;
par.A0 = A0;
par.x1 = x1;
par.x2 = x2;
par.x3 = x3;
par.deg = deg;
par.lkp = lkp;

return;
%_______________________________________________________________________

%_______________________________________________________________________
function [y1,y2,y3]=coords(p,M1,M2,x1,x2,x3)
% Rigid body transformation of a set of coordinates.
M  = (inv(M2)*inv(spm_matrix(p))*M1);
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
function A = make_A(M,x1,x2,x3,dG1,dG2,dG3,lkp)
p0 = [0 0 0  0 0 0  1 1 1  0 0 0];
A  = zeros(numel(x1),length(lkp));
for i=1:length(lkp)
	pt         = p0;
	pt(lkp(i)) = pt(i)+1e-6;
	[y1,y2,y3] = coords(pt,M,M,x1,x2,x3);
	tmp        = sum([y1-x1 y2-x2 y3-x3].*[dG1 dG2 dG3],2)/(-1e-6);
	A(:,i) = tmp;
end
return;
%_______________________________________________________________________