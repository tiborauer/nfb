function hdr = dicom_hdr(fn)
inf = spm_dicom_headers(img_file); 
    inf = inf{1};
    CSA = inf.CSAImageHeaderInfo;
    
    mat = sscanf(CSA(cell_index({CSA.name},'AcquisitionMatrixText')).item(1).val,'%d*%d');
    nSl = str2double(CSA(cell_index({CSA.name},'NumberOfImagesInMosaic')).item(1).val);
           
    hdr.Dimensions = [mat' nSl];
    hdr.PixelDimensions = [inf.PixelSpacing' inf.SpacingBetweenSlices];
    
    
analyze_to_dicom = [diag([1 -1 1]) [0 (dim(2)-1) 0]'; 0 0 0 1]*[eye(4,3) [-1 -1 -1 1]'];

vox    = [hdr{i}.PixelSpacing(:); hdr{i}.SpacingBetweenSlices];
pos    = hdr{i}.ImagePositionPatient(:);
orient = reshape(hdr{i}.ImageOrientationPatient,[3 2]);
orient(:,3) = null(orient');
if det(orient)<0, orient(:,3) = -orient(:,3); end;

% The image position vector is not correct. In dicom this vector points to
% the upper left corner of the image. Perhaps it is unlucky that this is
% calculated in the syngo software from the vector pointing to the center of
% the slice (keep in mind: upper left slice) with the enlarged FoV.
dicom_to_patient = [orient*diag(vox) pos ; 0 0 0 1];
truepos          = dicom_to_patient *[(size(mosaic)-dim(1:2))/2 0 1]';
dicom_to_patient = [orient*diag(vox) truepos(1:3) ; 0 0 0 1];
patient_to_tal   = diag([-1 -1 1 1]);
mat              = patient_to_tal*dicom_to_patient*analyze_to_dicom;



% Maybe flip the image depending on SliceNormalVector from 0029,1010
%-------------------------------------------------------------------
SliceNormalVector = read_SliceNormalVector(hdr{i});
if det([reshape(hdr{i}.ImageOrientationPatient,[3 2]) SliceNormalVector(:)])<0;
    volume = volume(:,:,end:-1:1);
    mat    = mat*[eye(3) [0 0 -(dim(3)-1)]'; 0 0 0 1];
end;
