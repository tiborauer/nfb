function fo = img_fliplr(fi)
for i = 1:size(fi, 3)
    fo(:,:,i) = fliplr(fi(:,:,i));
end
