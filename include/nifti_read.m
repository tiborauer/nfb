function [img, XYZ] = nifti_read(fn)
rem = {'rm','del'};
comp = strcmp(fn(end-1:end),'gz');
if comp
    fn = strrep(fn,'.gz','');
    gunzip([fn '.gz']);
end
[p, fn, e] = fileparts(fn);
fn = [fn e];
sd = '';
if ~isempty(p)
    sd = pwd;
    cd(p);
end
[img,XYZ] = spm_read_vols(spm_vol(fn));
for i = 1:size(img,4)
    img(:,:,:,i) = img_rot90(img(:,:,:,i)); % FSLView + Win = noFlipLR
end
if comp
    system([rem{ispc+1} ' ' fn]);
end
if ~isempty(sd), cd(sd); end