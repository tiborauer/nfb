function nfb(rtf)
% calls the neurofeedback GUI

% this file written by 
% Henry Luetcke (hluetck@gwdg.de) and
% Tibor Auer (tauer@gwdg.de)

fprintf('\n\nWelcome! This is nfb-toolbox version %s\n\n', nfb_ver);

if ~nargin
    rtf = nfb_open;
else
    rtf = nfb_open(rtf);
end

cd(fullfile(fileparts(which('nfb.m')),'gui'));
if ~isempty(rtf)
    gui_main_menu(1,'file', rtf);
else
    gui_main_menu(1);
end    

nfb_close;


