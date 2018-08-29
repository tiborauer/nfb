function fo = img_rot90(fi,n)
if nargin < 2, n = 1; end
nslice = size(fi,3);
for i = 1:nslice
    fo(:,:,i) = rot90(fi(:,:,i),n);
end
