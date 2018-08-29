% nfb_ReadVol_NW reads in the current epi volume once it is found in the
% watch folder
%
% USAGE:
% [out1, out2] = nfb_ReadVol_NW(in1, in2)
%
% in1 ... timepoint
% in2 ... timeout in seconds
% in3 ... moco
% in4 ... only used when moco = 1,2 --> reference file (or par for SPM Realign for moco)
% in5 ... only used when moco = 2 --> moco_del -> write for SPM Realign 
% out1 ... Matlab Analyze header structure
% out2 ... Image data (3D matrix)
% out3 ... 1 for success, 0 for failure (timeout reached)
% out4 ... SPM Realign: before initialization: 0
%                       after initialization: struct containing moco parameters 
%                       during moco: degree of motion corrected 

% this file written by Henry Luetcke (hluetck@gwdg.de)

function [hdr, img, status, par] = nfb_ReadVol_NW(varargin)

if nargin < 3
    disp('You MUST provide at least 3 input arguments');
    disp(' ');
    help nfb_ReadVol_NW
    return
end

if (varargin{3} == 2) && (nargin ~= 5)
    disp('When using SPM Realign, you MUST provide 5 output arguments');
    disp(' ');
    help nfb_ReadVol_NW
    return
end

global params;

n = varargin{1};
timeout = varargin{2};

status = 1;

par = 0; % default moco parameters

% base of filename (Analyze is the default)
data_basename = 'Analyze';

moco = varargin{3};
if moco
    moco_ref = varargin{4};
    if ischar(moco_ref) && strcmp(moco_ref,'first')
       moco_ref = sprintf('%s%05d.hdr',data_basename,1);
    end
end

hdr_root = sprintf('%s%05d.hdr',data_basename,n);
img_root = sprintf('%s%05d.img',data_basename,n);
fprintf('\nNow analysing file %s\n',hdr_root);

% first loop checks if both header and image exist
wait_time = clock;
file_wait = 1;
while (~exist(fullfile(pwd,hdr_root), 'file') ||...
        ~exist(fullfile(pwd,img_root), 'file'))
        % analysis may be aborted at the beginning of each cycle by pressing
        % cancel button in Experiment Info window

    if etime(clock,wait_time) > timeout
        fprintf(...
            '\nERRROR!!! File %s was not found in %s seconds! Aborting ...\n',...
            hdr_root,int2str(timeout));
        status = 0;
        hdr = 0;
        img = 0;
        return
    end
    if file_wait == 1
        fprintf('Waiting for file %s\n',hdr_root);
        fprintf('Seconds till timeout: ');
        sec2timeout = round(timeout-etime(clock,wait_time));
        diff_sec2timeout = sec2timeout;
        file_wait = 2;
    end
    if file_wait == 2
        sec2timeout = round(timeout-etime(clock,wait_time));
        if (diff_sec2timeout-sec2timeout) >= 5
            diff_sec2timeout = sec2timeout;
            fprintf('%s ',int2str(sec2timeout));
        end
    end
end

% second loop checks if the existing files can be read
fid_hdr = -1; fid_img = -1;
while (fid_hdr == -1) || (fid_img == -1)
    fid_hdr = fopen(hdr_root,'r');
    fid_img = fopen(img_root,'r');
end
fclose(fid_hdr);
fclose(fid_img);

if ~isfield(params.data,'hdr') 
    pos_root = sprintf('%s00001.pos',data_basename);
    fprintf('Loading data header from file\n');
    fid_pos = fopen(pos_root,'r');
    pos_hdr = textscan(fid_pos,'%s\t%s\n');
    fclose(fid_pos);
    
    nSl = str2double(pos_hdr{2}{cell_index(pos_hdr{1},'NrOfSlices')});
    mat = [str2double(pos_hdr{2}{cell_index(pos_hdr{1},'MatrixCols')})...
        str2double(pos_hdr{2}{cell_index(pos_hdr{1},'MatrixRows')})];
    FOV = [str2double(pos_hdr{2}{cell_index(pos_hdr{1},'FOVCols')})...
        str2double(pos_hdr{2}{cell_index(pos_hdr{1},'FOVRows')})];
    Th = str2double(pos_hdr{2}{cell_index(pos_hdr{1},'SliceThickness')}) +...
        str2double(pos_hdr{2}{cell_index(pos_hdr{1},'GapThickness')});
    
    params.data.hdr.Dimensions = [mat nSl];
    params.data.hdr.PixelDimensions = [FOV./mat Th];
end

%***************************** Timing Test ********************************
% hdr_root = fullfile('/realtime/nfb/Ana/Pilot4/tr_04',hdr_root);

% perform motion correction
switch moco
    case 0 % None
        hdr = spm_vol(hdr_root);
        img = spm_read_vols(hdr);
    case 2 % SPM Realign
        hdr = spm_vol(hdr_root);
        [img, P2] = spm_realign_fast(strrep(hdr.fname,'.hdr','.img'),moco_ref);
        % moco-parameters
        par = spm_realign_eval(moco_ref,P2,img,false);
        fprintf('Motion detected: %s\n', num2str(par));
%         if any(par(1:6) > 2)
%             fprintf('Motion detected exceeds the limit! Motion correction is discarded.\n' );
%             img = spm_read_vols(hdr);
%         end
end
hdr.Dimensions = params.data.hdr.Dimensions;
hdr.PixelDimensions = params.data.hdr.PixelDimensions;
% e.o.f.