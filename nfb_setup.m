function nfb_setup

fprintf('\n\nWelcome! This is nfb-toolbox version %s\nConfiguring path...\n',nfb_ver);

clear global params; % cleanup in case of a previos break-down
global params;

NFB_ROOTDIR = nfb_dir;
params.path.start_dir = pwd;
params.path.req{1} = NFB_ROOTDIR;
params.path.req{2} = fullfile(NFB_ROOTDIR, 'include'); 
params.path.req{3} = fullfile(NFB_ROOTDIR, 'train'); 
run(fullfile(NFB_ROOTDIR, 'include','path_add'));

if exist('finish','file')
    finish;
else
    savepath;
end

clear global params;

fprintf('Done!\n\n');

end