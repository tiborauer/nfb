% nfb_sanity performs sanity checks for neurofeedback analysis
%
% USAGE:
%
% to be called by nfb_main with rtconfig object as sole input
% returns status as first output:
% 0 ... success, no warnings
% 1 ... success, but warnings (run analysis)
% 2 ... failure (do not run)
% returns the new rtconfig as second output
% this file written by Henry Luetcke (hluetck@gwdg.de)
% and modified by Tibor Auer (Tibor.Auer@mrc-cbu.cam.ac.uk)

function varargout = nfb_sanity(rtconfig)
global params;

if nargin ~= 1
    disp('You MUST provide 1 input argument!');
    help nfb_sanity
    return
end

if ~isobject(rtconfig) || ~strcmp(class(rtconfig),'IniFile')
    disp('ERROR: You MUST provide an IniFile object as input!');
    help nfb_sanity
    varagout{1} = 2;
    varagout{2} = rtconfig;
    return
end

if ~rtconfig.isValid
    disp('ERROR: Configuration is not valid!');
    varagout{1} = 2;
    varagout{2} = rtconfig;
    return
end
varargout{1} = 0;

% check licences
tb = {'Statistical'};
func = {'ttest2'};
out = check_licence(func);
for i = 1:numel(out)
    if out(i)
        rtconfig.misc.eval = 0;
        fprintf('WARNING: %s Toolbox is not available!\n',tb{i});
        varargout{1} = max(varargout{1},1);
    end
end

% check if the configuration file contains all the required items
rtconfig.Sanity(fullfile(nfb_dir,'rtconfig_defaults.txt'));
if rtconfig.isModified
    fprintf('WARNING: some items were not found in the configuration file and were updated based on the default settings.\n');
    varargout{1} = max(varargout{1},1);
end

% check if the watch directory exists (if not it will be created)
if  ~strcmp(rtconfig.data.watch_dir,'net') && ~exist(rtconfig.data.watch_dir,'dir')
    fprintf('WARNING: Watch directory %s does not exist. Creating...',...
        rtconfig.data.watch_dir);
    stat = mkdir(rtconfig.data.watch_dir);
    if stat
        disp('Success!');
    else
        disp('ERROR:Failed!');
    end
    varargout{1} = max(varargout{1},2*~stat);
end

% check if spm convolution function is on path (if it is not and smoothing
% is demanded, throw warning and continue without smoothing)
if rtconfig.preprocess.smooth > 0 && ~exist('spm_conv_vol','file')
    fprintf('WARNING: Function spm_conv_vol was not found on Matlab path.\n');
    fprintf('\tData will NOT be smoothed!\n');
    rtconfig.preprocess.smooth = 0;
    varargout{1} = max(varargout{1},1);
end

% permitted values for roi_def are Nifti, BrainVoyager and Analyze
% check if ROI files exist (this is a little tedious, because if no path is
% given, they should be in the current directory, if watch_dir is empty, or
% in watch_dir)
switch rtconfig.data.roi_def
    case 'BrainVoyager'
        % nfb_roi2analyze will append the correct extension
        ext = '.roi';
    case 'Nifti'
        ext = '.nii';
    otherwise
        disp('ERROR: Permitted values for roi_def are BrainVoyager and Analyze.');
        varargout{1} = max(varargout{1},2);
end

if isempty(rtconfig.data.bg_roi)
    disp('WARNING! No background ROI specified. Analysing target ROI only ...');
    % it is allowed not to specify a background ROI, then we will just feed
    % back the target ROI intensity, not the difference
    varargout{1} = max(varargout{1},1);
else
    if ~file_exist(rtconfig, [rtconfig.data.bg_roi ext])
        [p f] = fileparts([rtconfig.data.bg_roi ext]);
        fprintf('WARNING: Backgound ROI file %s does not exist.\n', [f ext]);
        varargout{1} = max(varargout{1},1);
    end
end
% target
for i = 1:rtconfig.data.no_roi
    % target
    targ = [rtconfig.data.(['targ_roi' num2str(i)]) ext];
    [p f] = fileparts(targ);    
    f = strrep(targ,p,''); f = f(2:end);
    if ~file_exist(rtconfig, targ)
        fprintf('ERROR: Target ROI file %s does not exist.\n', f);
        varargout{1} = max(varargout{1},2);
        continue;
    end
    fprintf('Checking LR orientation...');
    flip_lr(i) = check_lr(targ);
%     if ~strcmp(rtconfig.data.watch_dir,'net')
%         rtconfig.data.flip_lr(i) = -rtconfig.data.flip_lr(i);
%     end
    switch flip_lr(i)
        case -1
            fprintf('Incorrect!\n');
        case 1
            fprintf('Correct!\n');
        otherwise
            fprintf('Not interpretable!\n');
    end
end
rtconfig.data.flip_lr = sum(flip_lr) < 0;
if rtconfig.data.flip_lr
    fprintf('WARNING: L/R Flip will be applied on ROIs!\n');
    varargout{1} = min(varargout{1},1);
end
            
% check if path for Presentation output file exists (if not it will be
% created)
if ~isempty(rtconfig.data.outfile)
    if strcmp(rtconfig.data.outfile,'net') % UDP
        if params.data.out.udp == -1
            fprintf('ERROR:UDP port %d cannot open!\n',port);
            varargout{1} = max(varargout{1},2); 
        end
    else % file
        outfile_dir = fileparts(rtconfig.data.outfile);
        if ~exist(outfile_dir,'dir')
            fprintf('WARNING: Presentation output file directory %s does not exist. \nCreating...',...
                outfile_dir);
            stat = mkdir(outfile_dir);
            if stat
                disp('Success!');
            else
                disp('ERROR:Failed!');
            end
            varargout{1} = max(varargout{1},2*~stat);
        end
    end
else
    disp('WARNING! No Presentation has been specified!');
    varargout{1} = max(varargout{1},1);
end

% check if output directory exists (if not it will be created)
if ~exist(rtconfig.data.output_dir,'dir')
    fprintf('WARNING: Output directory %s does not exist. \nCreating...',...
        rtconfig.data.output_dir);
    stat = mkdir(rtconfig.data.output_dir);
    if stat
        disp('Success!\n');
    else
        disp('ERROR:Failed!\n');
    end
    varargout{1} = max(varargout{1},2*~stat);
end

% if no background ROI is specified, plot type must be set to raw
if isempty(rtconfig.data.bg_roi) && strcmp(rtconfig.misc.plot_type,'diff')
    disp('WARNING! Cannot choose plot type "diff" without background ROI. "Raw" signal will be plotted!\n');
    rtconfig.misc.plot_type = 'raw';
    varargout{1} = max(varargout{1},1);
end

if rtconfig.timing.simul
    fprintf(...
        'WARNING! Emulation mode, processing will be delayed by %d seconds per volume\n',...
        rtconfig.timing.TR);
    varargout{1} = max(varargout{1},1);
end
fprintf('I will be analysing %d volumes\n',rtconfig.timing.volumes);

if isempty(rtconfig.data.tr_dir)
    rtconfig.data.tr_dir = strrep(rtconfig.data.output_dir,'_out','');
    disp(['WARNING! File transfer is not specified. Files will be transfered to default destination ('...
        rtconfig.data.tr_dir ')!...\n']);
    varargout{1} = max(varargout{1},1);
end

if exist(rtconfig.reference.ref_file,'file')
    ini_par = IniFile(rtconfig.reference.ref_file);
    if ~ini_par.isValid
        fprintf('ERROR! Paradigm file %s is not valid!\n',rtconfig.reference.ref_file);
        varargout{1} = max(varargout{1},2);
    end
else
    fprintf('ERROR! Paradigm file %s not found!\n',rtconfig.reference.ref_file);
    varargout{1} = max(varargout{1},2);
end

% check reference
varargout{1} = max(varargout{1},nfb_sanity_reference(rtconfig));

% check for MVPC
if rtconfig.reference.mv_MVPC
    model = rtconfig.reference.mv_Train;
    if isempty(model)
        fprintf('WARNING: No Trained Model specified!...Using normalization!\n');
        rtconfig.reference.mv_MVPC = 0;
        varargout{1} = max(varargout{1},1);
    else
        if ~exist(model,'file')
            fprintf('WARNING: Trained Model %s does not exist!...Using normalization!\n', model);
            rtconfig.reference.mv_MVPC = 0;
            varargout{1} = max(varargout{1},1);
        else
            load(model);
            rtconfig.reference.mv_Train = mvpc;
            rtconfig = rtconfig.ExcludeVariable('reference','mv_Train');
            fprintf('Trained Model %s exists\nChecking settings...\n', model);
            if ~strcmp(rtconfig.reference.mv_TrainData, mvpc.cfg.Path2Train)
                fprintf('WARNING: Training was accomplished with another dataset\n\tin directory %s\n', mvpc.cfg.Path2Train);
                rtconfig.reference.mv_TrainData = mvpc.cfg.Path2Train;
                fprintf('\tSetting corrected!\n');
                varargout{1} = max(varargout{1},1);
            end
            if ~strcmp(rtconfig.reference.mv_TrainRef, mvpc.cfg.RefDir_Train)
                fprintf('WARNING: Training was accomplished with another reference\n\tin directory %s\n', mvpc.cfg.RefDir_Train);
                rtconfig.reference.mv_TrainRef = mvpc.cfg.RefDir_Train;
                fprintf('\tSetting corrected!\n');
                varargout{1} = max(varargout{1},1);
            end
            if ~strcmp(rtconfig.reference.mv_Model, mvpc.cfg.Method)
                fprintf('WARNING: Training was accomplished with another model: %s\n', mvpc.cfg.Method);
                rtconfig.reference.mv_Model = mvpc.cfg.Method;
                fprintf('\tSetting corrected!\n');
                varargout{1} = max(varargout{1},1);
            end
            if rtconfig.reference.mv_Percent ~= mvpc.cfg.Perc
                fprintf('WARNING: Training was accomplished with other post-processing\n\tPercenting: %1.0u\n', mvpc.cfg.Perc);
                rtconfig.reference.mv_Percent = mvpc.cfg.Perc;
                fprintf('\tSetting corrected!\n');
                varargout{1} = max(varargout{1},1);
            end
            if rtconfig.reference.mv_bg ~= mvpc.cfg.Bg
                fprintf('WARNING: Training was accomplished with other post-processing\n\tBackground: %1.0u\n', mvpc.cfg.Bg);
                rtconfig.reference.mv_bg = mvpc.cfg.Bg;
                fprintf('\tSetting corrected!\n');
                varargout{1} = max(varargout{1},1);
            end
        end
    end
end

% if motion correction is requested, check if dependencies are fullfilled
stat = 1;
switch rtconfig.preprocess.moco_yn
    case 1 % McFLIRT
        stat = nfb_mcflirt('init');
    case 2 % Realign
        if ~exist('spm_realign','dir')
            disp('WARNING! Selected motion correction method: spm_realing - not exists! No motion correction will be performed.');
            stat = 0;            
        end
    otherwise % for dummies
        disp('WARNING! Undefined selection for motion correction method! No motion correction will be performed.');
        stat = 0;
end
if ~stat
    rtconfig.preprocess.moco_yn = 0;
    varargout{1} = max(varargout{1},1);
end

varargout{2} = rtconfig;
end

function res = file_exist(rtconfig, fn)
res = false;
if ~isempty(fileparts(fn))
    res = res | exist(fn,'file');
end
res = res | exist(fullfile(rtconfig.data.watch_dir,fn),'file');
end
% e.o.f.