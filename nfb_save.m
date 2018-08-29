% nfb_save saves important results after the experiment is done
%
% USAGE:
%
% nfb_save(in1,in2,in3,in4,in5);
%
% in1 ... config structure
% in2 ... results structure
% in3 ... handle to timeseries figure
% in4 ... full path to config file
% in5 ... full path to output_dir (optional - multile roi)

% this file written by Henry Luetcke (hluetck@gwdg.de)

% passing reference
function nfb_save(rtconfig,reference,ts_fig,outdir)

if nargin < 4
    disp('You MUST provide at least 4 input argument');
    help nfb_save
    return
end

current_dir = pwd;
if nargin == 5
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end
else
    outdir = rtconfig.data.output_dir;
end
cd(outdir);

rtconfig.Close(fullfile(outdir,'rtconfig.txt'));

fid = fopen('reference.txt','w');
fprintf(fid,'%1.0f\n', reference');
fclose(fid);

if ~strcmp(rtconfig.misc.plot_type,'no')
    clfcn = get(ts_fig,'CloseRequestFcn');
    set(ts_fig,'CloseRequestFcn','closereq');
    saveas(ts_fig,'timeseries.fig');
    set(ts_fig,'CloseRequestFcn', clfcn);
end
cd(current_dir);