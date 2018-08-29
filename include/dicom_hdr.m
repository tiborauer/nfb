function hdr = dicom_hdr(img_file)
inf = spm_dicom_headers(img_file);
inf = inf{1};
CSA = inf.CSAImageHeaderInfo;

mat = sscanf(CSA(cell_index({CSA.name},'AcquisitionMatrixText')).item(1).val,'%d*%d');
nSl = str2double(CSA(cell_index({CSA.name},'NumberOfImagesInMosaic')).item(1).val);

hdr.Dimensions = [mat' nSl];
hdr.PixelDimensions = [inf.PixelSpacing(:)' inf.SpacingBetweenSlices];

analyze_to_dicom = [diag([1 -1 1]) [0 (mat(2)-1) 0]'; 0 0 0 1]*[eye(4,3) [-1 -1 -1 1]'];

vox    = hdr.PixelDimensions';
pos    = inf.ImagePositionPatient(:);
orient = reshape(inf.ImageOrientationPatient,[3 2]);
orient(:,3) = null(orient');
if det(orient)<0, orient(:,3) = -orient(:,3); end;

dicom_to_patient = [orient*diag(vox) pos ; 0 0 0 1];
truepos          = dicom_to_patient *[([inf.Columns inf.Rows]-mat')/2 0 1]';
dicom_to_patient = [orient*diag(vox) truepos(1:3) ; 0 0 0 1];
patient_to_tal   = diag([-1 -1 1 1]);
mat              = patient_to_tal*dicom_to_patient*analyze_to_dicom;

% Maybe flip the image depending on SliceNormalVector from 0029,1010
%-------------------------------------------------------------------
SliceNormalVector = str2num([CSA(cell_index({CSA.name},'SliceNormalVector')).item.val]);
if det([reshape(inf.ImageOrientationPatient,[3 2]) SliceNormalVector(:)])<0
    mat    = mat*[eye(3) [0 0 -(dim(3)-1)]'; 0 0 0 1];
end
hdr.mat = mat;

