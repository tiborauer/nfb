function [img, hdr] = dicom_img(img_file,hdr)
if nargin < 2, hdr = dicom_hdr(img_file); end    

% mosaic = [];
% while isempty(mosaic)
%     try mosaic = double(dicomread(img_file)); catch; mosaic = []; end
% end
mosaic = double(dicomread(img_file));

% figure; imagesc(mosaic)
nm = ceil(sqrt(hdr.Dimensions(3)));
for s = 1:hdr.Dimensions(3)
    nx = rem(s-1,nm)+1;
    ny = ceil(s/nm);
%     fprintf('Slice %d: X = %d, Y = %d\n',s,nx,ny)
    img(:,:,s) = rot90(mosaic((ny-1)*hdr.Dimensions(2)+1:ny*hdr.Dimensions(2),...
        (nx-1)*hdr.Dimensions(1)+1:nx*hdr.Dimensions(1)),-1);
end