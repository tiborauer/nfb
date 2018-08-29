% convert a BrainVoyager ROI file into a 3D matrix for masking
% in1 ... roi file
% in2 ... Dimension from hdr info
% in3 ... flip top-to-bottom direction (true/false)

function [out1] = nfb_roi2analyze(in1,in2,in3)

roi = in1;
if isempty(strfind(roi,'.roi'))
    roi = [roi '.roi'];
end
Dimensions = in2;

roi_img = zeros(Dimensions);

fid = fopen(roi);
C{1} = '';
while ~strcmp(C{1},'NrOfPixels:')
   C = textscan(fid,'%s %d\n');
end
C = textscan(fid,'%d %d %d');
fclose(fid);

pixel_matrix(:,1) = C{1};
pixel_matrix(:,2) = C{2};
pixel_matrix(:,3) = C{3};

% all pixels listed in roi file are set to 1
% adjustment of coordinates: swap x-y / add 1 (found by trial-and-error)
for n = 1:(size(pixel_matrix,1))
   roi_img((pixel_matrix(n,2)+1),(pixel_matrix(n,1)+1),...
       (pixel_matrix(n,3)+1)) = 1;
end

if in3
    out1 = flipdim(roi_img,3);
else
    out1 = roi_img;
end