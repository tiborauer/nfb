% nfb_main is the main function of the Matlab Neurofeedback toolbox
% configuration is via a text file or IniFile object which may be specified
% as sole input argument (e.g. nfb_main('C:\Matlab\rtconfig.txt')) or will
% be selected by user interface
% sample neurofeedback configuration file is provided (rtconfig.txt)
% Note on timings provided: apart from the time for the total analysis (all
% volumes) given at the end of the experiment, 3 different timings are
% specified for each volume
% Volume time ... total analysis time for volume (includes waiting time if
% the volume has not been written)
% Processing time ... time required to process a volume that has been read
% until feedback is given (does not include plotting)

% this file written by
% Henry Luetcke (hluetck@gwdg.de) and
% Tibor Auer (Tibor.auer@mrc-cbu.cam.ac.uk)

function nfb_main(rtconfig)

if ~nargin
    rtconfig = nfb_open;
else
    rtconfig = nfb_open(rtconfig);
end

global params CANCEL PAUSE ROI ROI_CHNG;
try
    % perform sanity checks before starting
    [sanity_checks, rtconfig] = nfb_sanity(rtconfig);
    switch sanity_checks
        case 2
            nfb_close('Errors occured while parsing the configuration file. Exiting ...')
            return
        case 1
            disp('Warnings occured while parsing the configuration file.');
            pause(2);
        case 0
            disp('Passed all sanity checks. Proceeding with analysis.');
    end
    % some variables get short alias
    volumes = rtconfig.timing.volumes;
    timeout = rtconfig.timing.timeout;
    roi_flip = rtconfig.data.flip_slice;
    out_dir = rtconfig.data.output_dir; if isempty(out_dir), out_dir = start_dir; end
    outfile = rtconfig.data.outfile;
    moco = rtconfig.preprocess.moco_yn;
    moco_del = rtconfig.preprocess.moco_del;
    smooth_fwhm = rtconfig.preprocess.smooth;
    
    % build the reference function (0 for rest,+1 for active,-1 for deactive)
    params.reference = nfb_reference(rtconfig);
    rtconfig.timing.ndt = rtconfig.timing.TR/params.reference.dt;
    rtconfig.timing.timepoints = rtconfig.timing.volumes*rtconfig.timing.ndt;
    
    nr = rtconfig.data.no_roi;
    if isempty(nr)
        nr = 1;
        ROI = 1;
        results(1) = nfb_analyzer('init',rtconfig);
    else
        for i = 1:nr
            ROI(i) = rtconfig.data.(['w_roi' num2str(i)]);
            results(i) = nfb_analyzer('init',rtconfig);
        end
    end
    if rtconfig.reference.mv_MVPC
        ROI = rtconfig.reference.mv_Train.cfg.ROI;
    end
    
    % setup figures
    % obtaining the handles of the figures, plots, bars and axes (ts_fig)
    % obtaining name of ROIS
    [ts_fig,targ_rois] = nfb_figurecreate(rtconfig);
    % bring fb_control to front -> roi selection
    figure(ts_fig.fb_control);
    
    % Enter the analysis directory
    params.path.start_dir = pwd;
    if ~isempty(rtconfig.data.watch_dir)
        if strcmp(rtconfig.data.watch_dir,'net')
            [ip,port] = pnet(params.data.watch.con,'gethost');
            fprintf('Now processing volumes from host:%d.%d.%d.%d port: %d\n',ip,port);
        elseif exist(rtconfig.data.watch_dir,'dir')
            params.data.watch = rtconfig.data.watch_dir;
            fprintf('Now changing working directory to %s\n',params.data.watch);
            cd(params.data.watch);
        end
    else
        fprintf('Now processing files in directory %s\n',params.path.start_dir);
    end
    
    if ~rtconfig.misc.run
        nfb_close(sprintf('Configuration settings appear ok.\nExiting...'));
        return
    end
    
    if moco
        moco_ref = rtconfig.preprocess.moco_ref;
    end
    
    params.clocks.exp = clock;
    save(fullfile(out_dir,'params.mat'),'params');
    
    % start evaluation loop for each volume
    n = 1;
    status = true;
    params.reference.norm_start = 0;
    params.reference.norm_stop = 0;
    params.clocks.volume = clock;
    
    while n <= rtconfig.timing.volumes
        if rtconfig.timing.simul, params.clocks.simul = clock; end
        
        % analysis may be paused at the beginning of each cycle by pressing
        % pause button in Experiment Info window
        if PAUSE
            fprintf('\nPause request granted at %s\n\n',datestr(clock,13));
            while PAUSE && ~CANCEL
                % here pause is needed to give time to change the status of the buttons
                pause(0.1);
            end
            if ~PAUSE
                fprintf('\nResume request granted at %s\n\n',datestr(clock,13));
            end
        end
        % analysis may be aborted at the beginning of each cycle by pressing
        % cancel button in Experiment Info window
        if CANCEL
            break
        end
        
        if status, fprintf('Now waiting for volume %d: %6.3fs\n',n,etime(clock,params.clocks.volume)); end
        if moco
            if strcmp(rtconfig.data.watch_dir,'net')
                [epi_hdr, current_epi, status, par] = nfb_ReadVol(n,moco,moco_ref,moco_del);
            else
                [epi_hdr, current_epi, status, par] = nfb_ReadVol_NW(n,timeout,moco,moco_ref,moco_del);
            end
            if status
                % SPM Realign Inittime
                if isstruct(par)
                    moco_ref = par;
                    % moco-parameters from SPM Realign
                elseif sum(par)
                    moco_list(n,:) = par;
                    params.reference.moco_par(n,1:6) = par(1:6);
                end
            end
        else
            if strcmp(rtconfig.data.watch_dir,'net')
                [epi_hdr, current_epi, status] = nfb_ReadVol(n,moco);
            else
                [epi_hdr, current_epi, status] = nfb_ReadVol_NW(n,timeout,moco);
            end
        end
        if ~status && etime(clock,params.clocks.volume) > timeout
            % delete moco volumes if requested
            if (moco == 1) && moco_del
                delete('*_mc.hdr'); delete('*_mc.img');
            end
            nfb_close(sprintf('No volume arrived in %6.3f s',timeout),struct('GUI',false));
            return
        end
        
        if status
            volume_time = etime(clock,params.clocks.volume);
            params.clocks.volume = clock;
            params.clocks.proc = clock;
            
            % get dimensions, voxel size and ROI matrices
            if n == 1
                dims = epi_hdr.Dimensions;
                voxel_size = epi_hdr.PixelDimensions;
                mask = 0;
                for ir = 1:nr
                    targ{ir} = rtconfig.data.(['targ_roi' num2str(ir)]);
                    if strcmp(basename(targ{ir}),'mask'), mask=ir; end
                end
                bg_img = rtconfig.data.bg_roi;
                bg = ~isempty(bg_img);
                switch rtconfig.data.roi_def
                    case'BrainVoyager'
                        for ti = 1:nr
                            targ_img(:,:,:,ti) = logical(nfb_roi2analyze(targ{ti},dims, roi_flip));
                        end
                        if bg
                            bg_img = logical(nfb_roi2analyze(bg_img,dims, roi_flip));
                        end
                    case 'Nifti'
                        for ti = 1:nr
                            targ_img(:,:,:,ti) = logical(spm_read_vols(spm_vol([targ{ti} '.nii'])));
                        end
                        if bg
                            bg_img = logical(spm_read_vols(spm_vol([bg_img '.nii'])));
                        end
                end
                
                mv_targ_img = false(dims(1:3));
                for ti = 1:nr
                    if rtconfig.data.flip_lr
                        targ_img(:,:,:,ti) = img_flipud(targ_img(:,:,:,ti));
                        bg_img = img_flipud(bg_img);
                    end
                    
                    mv_targ_img = mv_targ_img | targ_img(:,:,:,ti);
                end
                
                if mask
                    mask_img = targ_img(:,:,:,mask);
                    i_lt = prctile(current_epi(mask_img),2);
                    i_ut = prctile(current_epi(mask_img),98);
                    i_t = i_lt + i_ut/10;
                    targ_img(:,:,:,mask) = logical((current_epi > i_t).*mask_img);
                end
                
                % smooth the image
                % for accurate and efficient smoothing we use the spm_conv_vol function
                % (part of SPM)
                if smooth_fwhm > 0
                    kernel = repmat(smooth_fwhm,[1 3]);
                    % from spm_smooth
                    % Copyright (C) 2005 Wellcome Department of Imaging Neuroscience
                    % compute parameters for spm_conv_vol
                    %------------------------------------------------------------------
                    dimx = double(voxel_size(1));
                    dimy = double(voxel_size(2));
                    dimz = double(voxel_size(3));
                    kernel  = kernel./[dimx dimy dimz]; % voxel anisotropy
                    kernel  = max(kernel,ones(size(kernel))); % lower bound on FWHM
                    kernel  = kernel/sqrt(8*log(2));    % FWHM -> Gaussian parameter
                    
                    x_par  = round(6*kernel(1)); x_par = -x_par:x_par;
                    y_par  = round(6*kernel(2)); y_par = -y_par:y_par;
                    z_par  = round(6*kernel(3)); z_par = -z_par:z_par;
                    x_par  = exp(-(x_par).^2/(2*(kernel(1)).^2));
                    y_par  = exp(-(y_par).^2/(2*(kernel(2)).^2));
                    z_par  = exp(-(z_par).^2/(2*(kernel(3)).^2));
                    x_par  = x_par/sum(x_par);
                    y_par  = y_par/sum(y_par);
                    z_par  = z_par/sum(z_par);
                    
                    i_par  = (length(x_par) - 1)/2;
                    j_par  = (length(y_par) - 1)/2;
                    k_par  = (length(z_par) - 1)/2;
                    %------------------------------------------------------------------
                end
            end
            
            if smooth_fwhm > 0
                smoothed_epi = zeros(dims);
                spm_conv_vol(current_epi,smoothed_epi,x_par,y_par,z_par,-[i_par,j_par,k_par]);
                current_epi = smoothed_epi;
            end
            %%%%%%%%%%%%%%%%%%%%% DATA READ %%%%%%%%%%%%%%%%%%%%%%%%
            
            % set normalisation
            if std(params.reference.vec.norm) % non-uniform
                if params.reference.vec.norm(n)
                    if ~params.reference.norm_start || params.reference.norm_stop
                        params.reference.norm_start = n;
                        params.reference.norm_stop = 0;
                    end
                else
                    if params.reference.norm_start && ~params.reference.norm_stop
                        params.reference.norm_stop = n-1;
                    end
                end
            else % uniform --> norm: FB - FB
                if params.reference.vec.fb(n)
                    if ~params.reference.norm_start || params.reference.norm_stop
                        params.reference.norm_start = n;
                        params.reference.norm_stop = 0;
                    end
                else
                    if (n < rtconfig.timing.volumes) && params.reference.vec.fb(n+1)
                        params.reference.norm_stop = n;
                    end
                end
            end
            
            if rtconfig.reference.mv_MVPC
                tdata = current_epi(mv_targ_img); bdata = 0;
                if bg, bdata = current_epi(bg_img); end
                [results(1) norm_par(1)] = nfb_dataread_mvpc(results(1),rtconfig,tdata,bdata,n,norm_par(1));
                ROI = 1;
            else
                for ir = 1:nr
                    % extract mean ROI in target and background ROI
                    tdata = mean(current_epi(targ_img(:,:,:,ir))); bdata = 0;
                    if bg, bdata = mean(current_epi(bg_img)); end
                    results(ir) = nfb_dataread(results(ir), rtconfig,tdata,bdata,n);
                end
            end
            
            % write color and timepoint to a file for reading with Presentation
            for ir = 1:numel(ROI)
                outres(ir) = results(ir).ts(n,10);
            end
            outres = nfb_combine(outres,ROI);
            if isnan(outres), outres = 11; end %%%%%%% temporary fix
            if ~isempty(outfile)
                if strcmp(rtconfig.data.outfile,'net') % UDP
                    if outres
                        pnet(params.data.out.udp,'write',outres);
                        pnet(params.data.out.udp,'writepacket',params.data.out.host,params.data.out.port);
                        fprintf('Fb %d has been sent to %s\n',outres,params.data.out.host);
                    end
                else % file
                    while exist(outfile,'file')
                        pause(0.1);
                    end
                    if outres
                        fid = fopen(outfile,'w');
                        fprintf(fid,'%s\t%s',int2str(n),int2str(outres));
                        fclose(fid);
                        %                 else
                        %                     if exist(outfile,'file')
                        %                         delete(outfile);
                        %                     end
                    end
                end
            end
            
            for ir = 1:nr
                fprintf('Target ROI %s: %s\n', num2str(ir), num2str(results(ir).ts(n,3)));
            end
            if ~isempty(bg)
                fprintf('Background ROI: %s\n',num2str(results(1).ts(n,4)));
            end
            % report usage of ROIs and FB
            fprintf('Scan %s.\t\tROI-Weight(s): %s\n', int2str(n), num2str(ROI));
            fprintf('Feedback level: %d.\n', outres);
            % delete moco volumes if requested
            if moco && moco_del
                delete('*_mc.hdr'); delete('*_mc.img');
            end
            
            if rtconfig.misc.plot_type
                % plot the timeseries (either difference or raw ROI intensities)
                ts_fig = nfb_plot(rtconfig,results,ts_fig,n);
            end
            
            proc_time = etime(clock,params.clocks.proc);
            for ir = 1:nr
                results(ir).ts(n,11) = volume_time;
                results(ir).ts(n,12) = proc_time;
            end
            fprintf('Volume time %6.3f seconds\n',volume_time);
            fprintf('Processing time %6.3f seconds\n',proc_time);
            % reset sign of ROI change
            ROI_CHNG = false;
            n = n + 1;
        end
        
        if rtconfig.timing.simul
            while etime(clock,params.clocks.simul) < rtconfig.timing.TR
                pause(0.01);
            end
        end
    end
catch err
    % delete moco volumes if requested
    if exist('moco','var') && moco && moco_del
        delete('*_mc.hdr'); delete('*_mc.img');
    end
    
    msg = sprintf('Error occurred: %s\n',err.message);
    for e = 1:numel(err.stack)
        msg = [msg sprintf('in %s (line %d)\n', ...
            err.stack(e).file, err.stack(e).line)];
    end
    
    nfb_close(msg,false);
    return
end

fprintf('Experiment finished on %s. It took %6.3f seconds\n',...
    datestr(clock),etime(clock,params.clocks.exp));

if CANCEL
    % delete moco volumes if requested
    if moco && moco_del
        delete('*_mc.hdr'); delete('*_mc.img');
    end
    nfb_close(sprintf('\nTermination request granted at %s\n',datestr(clock,13)),struct('GUI',false,'files',false));
    return
end

diary off;

% write experiment specific info to results structure
h = findobj('Name','Experiment Info');
hC = get(h,'Children');
for i = 1:numel(hC)
    if strcmp(get(hC(i),'Tag'),'info_text'), break, end
end
str = get(hC(i),'String');
info = info_parser(str);

% perform evaluation of resultsref
wait_bar = waitbar(0,'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
set(wait_bar, 'Units','normalized');
pos = get(wait_bar, 'Position');
pos(2) = pos(2) - 0.25;
set(wait_bar, 'Position',pos);
set(get(get(wait_bar,'Children'),'Title'),'Interpreter','None')

% create result for Measured
nr = nr + 1;
targ_rois{nr} = 'Measured';
results(nr) = nfb_analyzer('init',rtconfig);
ts = results(nr-1).ts;
for c = 3:10 % columns
    for n = 1:size(ts, 1) % timepoints
        dat = [];
        for ir = 1:nr-1 % read data from rois
            dat(ir) = results(ir).ts(n,c);
        end
        ts(n,c) = nfb_combine(dat,ROI);
    end
end
results(nr).ts = ts;

for ir = 1:nr
    savedir = fullfile(out_dir, ['ROI_' targ_rois{ir}]);
    bar_text = ['Now saving results in ' savedir];
    waitbar((ir-1+0.2)/nr,wait_bar,bar_text);
    if ~exist(savedir,'dir'), mkdir(savedir); end
    if rtconfig.misc.eval
        result = nfb_analyzer('eval',results(ir),rtconfig,...
            fullfile(out_dir, ['ROI_' targ_rois{ir}]));
    else
        result = results(ir);
    end
    result.info = info;
    waitbar((ir-1+0.6)/nr);
    save(fullfile(savedir, 'results.mat'),'result');
    waitbar(ir/nr);
end

waitbar(0, wait_bar, ['Now saving settings in ' out_dir]);
% save important stuff in output dir
nfb_save(rtconfig,result.ts(:,2),ts_fig.main,out_dir);
waitbar(0.5, wait_bar);

% display and save moco parameters from SPM Realign
if moco == 2
    % eliminates the big jump caused by registering to an other session ->
    % every parameters will be shown as a difference from the second scan
    for i = volumes:-1:1
        moco_list(i,:) = moco_list(i,:) - moco_list(2,:);
    end
    figure(100);
    subplot(2,1,1);
    plot(moco_list(:,1:3), 'LineWidth',2);
    xlim([1 rtconfig.timing.volumes]);
    title('Translation Detected and Corrected');
    xlabel('Time (scan)');
    ylabel('Motion (mm)');
    legend({'Translation - X', 'Translation - Y', 'Translation - Z'}, 'location','NorthEastOutside');
    subplot(2,1,2);
    plot(moco_list(:,4:6), 'LineWidth',2);
    xlim([1 rtconfig.timing.volumes]);
    title('Rotation Detected and Corrected');
    xlabel('Time (scan)');
    ylabel('Motion (deg)');
    legend({'Rotation    - X', 'Rotation    - Y', 'Rotation    - Z'}, 'location','NorthEastOutside');
    drawnow
    saveas(100, fullfile(out_dir, 'MoCo.fig'));
    figure(100);
    subplot(1,1,1);
    plot(moco_list(:,7), 'LineWidth',2);
    xlim([1 rtconfig.timing.volumes]);
    title('Total Motion Detected and Corrected');
    xlabel('Time / Images');
    ylabel('Motion (Square Root of Sum of Squares of all Motion)');
    drawnow
    saveas(100, fullfile(out_dir, 'MoCo_SquareRootofSumOfSquares.fig'));
    save(fullfile(out_dir, 'moco.mat'),'moco_list');
    close(100);
end
waitbar(1,wait_bar);
close(wait_bar);
if ~strcmp(rtconfig.data.watch_dir,'net') && ~strcmp(rtconfig.data.tr_dir,'none')
    file_transfer(rtconfig.data.watch_dir,rtconfig.data.tr_dir);
end
nfb_close(false,struct('GUI',false,'files',false));
end