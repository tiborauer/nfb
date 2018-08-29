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

function [hdr, img, status, par] = nfb_ReadVol_dcm(varargin)

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

DIR = fullfile(params.data.watch,sprintf('%s.%s.%s',datestr(date,'yyyymmdd'),params.data.LastName,params.data.ID));

fprintf('\nNow analysing file: #%03d\n',n);

% loop checks if image exist
wait_time = clock;
file_wait = 1;
while true
    % analysis may be aborted at the beginning of each cycle by pressing
    % cancel button in Experiment Info window
    if n == 1
        d = dir(fullfile(DIR,sprintf('*_*_%06d.dcm',n)));
        if ~isempty(d)
            dat = sscanf(d(1).name,'%03d_%06d_000001.dcm');
            params.data.subject = dat(1);
            params.data.session = dat(2);
            break
        end        
    else
        if exist(fullfile(DIR,sprintf('%03d_%06d_%06d.dcm',params.data.subject,params.data.session,n)),'file')
            break
        end
    end

    if etime(clock,wait_time) > timeout
        fprintf(...
            '\nERROR!!! File %s was not found in %s seconds! Aborting ...\n',...
            hdr_root,int2str(timeout));
        status = 0;
        hdr = 0;
        img = 0;
        return
    end
    if file_wait == 1
        fprintf('Waiting for file: #%03d\n',n);
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

img_file = fullfile(DIR,sprintf('%03d_%06d_%06d.dcm',params.data.subject,params.data.session,n));

% wait until the whole file is there
d = dir(img_file);
while d.bytes < (180*1024+(64*64*28*2)) % 180kB header + res*2bytes image
    d = dir(img_file);
end

% read
if isfield(params.data,'hdr') 
    [img, hdr] = dicom_img(img_file,params.data.hdr);
else
    [img, hdr] = dicom_img(img_file);
    params.data.hdr = hdr;
end

% perform motion correction
moco = varargin{3};
if moco
    moco_ref = varargin{4};
    if ischar(moco_ref) && strcmp(moco_ref,'first')
       moco_ref = fullfile(DIR,sprintf('001_%06d_%06d.dcm',params.data.session,1));
    end
    
    if ~isstruct(moco_ref) % initialize spm_realign
        if exist(moco_ref,'file')
            par = spm_realign_init(moco_ref);
            par.write = ~varargin{5}; % moco_del
            fprintf('Motion correction initialized.\n%s was set as reference scan.\nMotion correction was not made for this scan!\n', moco_ref);
        else
            fprintf('Reference scan (%s) for motion correction does not exist!\nNo motion correction can be made!\n', moco_ref);
            par = 0;
        end
    else % run spm_realign
        hdr.dat = img;
        [img, P2] = spm_realign_fast(hdr,moco_ref);
        % moco-parameters
        par = spm_realign_eval(moco_ref,P2);
        fprintf('Motion detected: %s\n', num2str(par));
        %             if any(par(1:6) > 2)
        %                 fprintf('Motion detected exceeds the limit! Motion correction is discarded.\n' );
        %                 img = spm_read_vols(hdr);
        %             end
    end
end
% e.o.f.