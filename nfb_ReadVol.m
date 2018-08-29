% nfb_ReadVol reads in the current epi volume via TCP/UDP/IP
%
% USAGE:
% [out1, out2] = nfb_ReadVol(in1, in2)
%
% in1 ... timepoint
% in2 ... moco
% in3 ... only used when moco = 2 --> reference file (or par for SPM Realign for moco)
% in4 ... only used when moco = 2 --> moco_del -> write for SPM Realign 
% out1 ... reduced Analyze header structure
% out2 ... Image data (3D matrix)
% out3 ... 1 for success, 0 for failure (timeout reached)
% out4 ... SPM Realign: before initialization: 0
%                       after initialization: struct containing moco parameters 
%                       during moco: degree of motion corrected 

% this file written by Henry Luetcke (hluetck@gwdg.de)

function [hdr, img, status, par] = nfb_ReadVol(varargin)

if nargin < 2
    disp('You MUST provide at least 3 input arguments');
    disp(' ');
    help nfb_ReadVol_NW
    return
end

if (varargin{2} == 2) && (nargin ~= 4)
    disp('When using SPM Realign, you MUST provide 4 output arguments');
    disp(' ');
    help nfb_ReadVol_NW
    return
end

global params;

n = varargin{1};

status = 1;

par = 0; % default moco parameters

moco = varargin{2};
if moco
    moco_ref = varargin{3};
end

fprintf('\b\b\b\b\b\b\b\b%6.3fs\n',etime(clock,params.clocks.volume));

while 1
    dat = read_packet(params.data.watch.con);

    if isempty(dat)
        status = 0;
        hdr = 0;
        img = 0;
        return
    end
    
    if dat.code == 8 % receive header
        mat = double(dat.data)';
        d(:,4) = sum(mat(:,1:3),2);
        m = ones(3,4); m(1:2,:) = -1;
        params.data.hdr.mat = vertcat((mat-d).*m,[0 0 0 1]);
        R = params.data.hdr.mat(1:3,1:3);
        params.data.hdr.PixelDimensions = abs(diag(chol(R'*R)))';
    end
    
    if dat.code == 10, break; end
end

% In case of missing header (only for sample)
if ~isfield(params.data,'hdr')
    hdr_file = fullfile(params.path.nfb_rootdir,'sample','dat.mat');
    if exist(hdr_file,'file')
        fprintf('Loading data header from file\n');
        load(hdr_file);
        params.data.hdr.mat = sim.mat;
        params.data.hdr.PixelDimensions = [sim.PixelSpacing' sim.SpacingBetweenSlices];
    end
end

img = dat.data;
hdr = params.data.hdr;
hdr.Dimensions = size(img);

V.mat = hdr.mat;
V.dat = img;

% perform motion correction
switch moco
    case 2 % SPM Realign
        if ~isstruct(moco_ref) % initialize spm_realign
            if strcmp(moco_ref,'first')
                par = spm_realign_init(V);
                par.write = ~varargin{4}; % moco_del
                fprintf('Motion correction initialized.\n%s was set as reference scan.\nMotion correction was not made for this scan!\n', moco_ref);
            elseif exist(moco_ref,'file')
                moco_ref = strrep(moco_ref,'.hdr','.img');
                par = spm_realign_init(moco_ref);
                par.write = ~varargin{4}; % moco_del
                fprintf('Motion correction initialized.\n%s was set as reference scan.\nMotion correction was not made for this scan!\n', moco_ref);
            else
                fprintf('Reference scan (%s) for motion correction does not exist!\nNo motion correction can be made!\n', moco_ref);
                par = 0;
            end
        else % run spm_realign
            [img, P2] = spm_realign_fast(V,moco_ref);
            % moco-parameters
            par = spm_realign_eval(moco_ref,P2,img,false);
            fprintf('Motion detected: %s\n', num2str(par));
%             if any(par(1:6) > 2)
%                 fprintf('Motion detected exceeds the limit! Motion correction is discarded.\n' );
%                 img = dat.data;
%             end
        end
end
% e.o.f.