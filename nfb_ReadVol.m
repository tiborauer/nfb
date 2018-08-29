% nfb_ReadVol reads in the current epi volume via TCP/IP
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
    disp('You MUST provide at least 2 input arguments');
    disp(' ');
    help nfb_ReadVol
    return
end

if (varargin{2} == 2) && (nargin ~= 4)
    disp('When using SPM Realign, you MUST provide 4 output arguments');
    disp(' ');
    help nfb_ReadVol
    return
end

global params;

status = 1;

par = 0; % default moco parameters

fprintf('\b\b\b\b\b\b\b\b%6.3fs\n',etime(clock,params.clocks.volume));

[hdr, img] = params.data.watch.ReceiveScan;

% perform motion correction
moco = varargin{2};
if moco
%     img0 = img;
    moco_ref = varargin{3};
    hdr.dat = img;
    [img, P2] = spm_realign_fast(hdr,moco_ref);
    % moco-parameters
    par = spm_realign_eval(moco_ref,P2);
    fprintf('Motion detected: %s\n', num2str(par));
%     if any(par(1:6) > 2)
%         fprintf('Motion detected exceeds the limit! Motion correction is discarded.\n' );
%         img = img0;
%     end
end
% e.o.f.