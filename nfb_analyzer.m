% nfb_analyzer is the analysis function of the Neurofeedback toolbox
% during the experiment it collects data points
% after the experiment it runs some stats, plots results etc.
%
% USAGE:
%
% in1 ... string with instruction what to do
%     'init' ... set up the result structure
%     'eval' ... evaluate the result structure
%     'offline' ... post-experiment analysis of result structure
% further inputs depend on in1:
% 'init' requires
%     in2: rtconfig
% 'eval' requires
%     in2: results
%     in3: rtconfig
% 'offline' requires
%     in2: full path to results.mat
%     in3: shift
% optional inputs
%     in4: output directory
%     in5: full path to MoCoValue file as provided by MoCoParameters.m
% 
% this file written by Henry Luetcke (hluetck@gwdg.de) and
% Tibor Auer (Tibor.auer@mrc-cbu.cam.ac.uk)

function [result] = nfb_analyzer(varargin)

if nargin < 2
    disp('Please pass at least 3 input argument');
    help nfb_analyzer
    return
end

global params;

switch varargin{1}
    case 'init'
        vols = numel(params.reference.vec.reference);
        % set up a structure that holds various results from the analysis
        result.ts = zeros(vols,12);
        if varargin{2}.reference.mv_MVPC
            result.ts_columns = {'Timepoint' 'Reference' 'Target ROI Intensity' ...
                'Background ROI Intensity' 'Class(to plot)' 'Not in use' 'TargPreproc' 'BgPreproc' ...
                'Class' 'FB Color' 'VolumeTime' 'ProcessingTime'};
        else
            result.ts_columns = {'Timepoint' 'Reference' 'Target ROI Intensity' ...
                'Background ROI Intensity' 'Targ-lp' 'Bg-lp' 'TargPerc' 'BgPerc' ...
                'DiffPerc' 'FB Color' 'VolumeTime' 'ProcessingTime'};
        end
        result.ts(1:vols,1) = 1:vols;
        result.ts(:,2) = params.reference.vec.reference;
		result.internal = [];
    case {'eval', 'offline'}
        if strcmp(varargin{1}, 'eval')
            result = varargin{2};
            rtconfig = varargin{3};
            out_dir = rtconfig.data.output_dir;
            tr = rtconfig.timing.TR;
            shift = 3;
        else % offline
            load(varargin{2});
            if isempty(params), load(fullfile(fileparts(varargin{2}),'..','params.mat')); end
            shift = varargin{3};
            out_dir = result.info{5,2};
            tr = str2double(result.info{2,2});
        end
        
        if nargin > 3
            out_dir = varargin{4};
            % checkng existence of out_dir
            if ~exist(out_dir,'dir')
                if ~mkdir(char(out_dir))
                    error('Could not create output directory. Exiting ...');
                end
            end
        end
        % obtain name of ROI
        roi_name = [strrep(out_dir(strfind(out_dir,'ROI'):end),'ROI_','ROI(') ')'];
        
        timepoints = result.ts(:,1);
        ref_noshift = result.ts(:,2);
        mean_targ = result.ts(:,3);
        mean_bg = result.ts(:,4);
        mean_diff = result.ts(:,3)-result.ts(:,4);
        % correct the first data because of moco
        mean_targ(1) = mean_targ(2);
        mean_bg(1) = mean_bg(2);
        mean_diff(1) = mean_diff(2);
        
        % shift the reference function by 2 volumes
        ref_shift = [zeros(shift,1); ref_noshift(1:length(timepoints)-shift)];
        
        % check if background ROI exists
        bg_found = any(mean_bg);

        % timeseries filters: if mpi_BandPassFilterTimeSeries is found on path
        % we use it for temporal filtering, otherwise some simpler low and high
        % pass filters are applied
        % estimate length of the paradigm's repeating unit from the data
        % (assume regular paradigm, ignore baseline)
        par_length = nfb_parest(ref_noshift);
        % this filter operates in the time domain and therefore requires TR
        % first we must estimate the cut-off frequencies in Hz for low- and
        % high-pass filters
        % cut-off frequency for hp filter is determined by paradigm length
        % and should be a little longer than the paradigm
        par_length = par_length * tr;
        f_low = 1 / (1.1*par_length);
        % cut-off frequency for lp filter is determined by TR
        f_high = 1 / (2*tr);
        mean_targ_filt = mpi_BandPassFilterTimeSeries(mean_targ, tr, f_low, f_high)+mean(mean_targ);
        if bg_found
            mean_bg_filt = mpi_BandPassFilterTimeSeries(mean_bg, tr, f_low, f_high)+mean(mean_bg);
            mean_diff_filt = mpi_BandPassFilterTimeSeries(mean_diff, tr, f_low, f_high)+mean(mean_diff);
        end        
        
        % plot the raw timecourse and difference
        timeseries = mean_targ';
        if bg_found, 
            timeseries(2,:) = mean_bg';
            h = plot_timecourse(timepoints,mean_diff',{},ref_noshift,roi_name);
            fig_save = fullfile(out_dir,'roi_difference.fig');
            saveas(h,fig_save);
            close(h);
        end
        h = plot_timecourse(timepoints,timeseries,{},ref_noshift,roi_name);
        fig_save = fullfile(out_dir,'roi_timecourses.fig');
        saveas(h,fig_save);
        close(h);

        % plot the filtered timecourse and difference
        timeseries = mean_targ_filt;
        if bg_found, 
            timeseries(2,:) = mean_bg_filt;
            h = plot_timecourse(timepoints,mean_diff_filt,{},ref_noshift,roi_name);
            fig_save = fullfile(out_dir,'roi_difference_filtered.fig');
            saveas(h,fig_save);
            close(h);
        end
        h = plot_timecourse(timepoints,timeseries,{},ref_noshift,roi_name);
        fig_save = fullfile(out_dir,'roi_timecourses_filtered.fig');
        saveas(h,fig_save);
        close(h);
        
        % collect results in vectors (active, [deactive], rest)
        act_targ_vector = mean_targ_filt(ref_shift==1);
        deact_targ_vector = mean_targ_filt(ref_shift==-1);
        rest_targ_vector = mean_targ_filt(ref_shift==0);
        if bg_found
            act_bg_vector = mean_bg_filt(ref_shift==1);
            deact_bg_vector = mean_bg_filt(ref_shift==-1);
            rest_bg_vector = mean_bg_filt(ref_shift==0);
            act_diff_vector = mean_diff_filt(ref_shift==1);
            deact_diff_vector = mean_diff_filt(ref_shift==-1);
            rest_diff_vector = mean_diff_filt(ref_shift==0);
        end
        
        % calculate descriptive stats
        mean_rest_targ = mean(rest_targ_vector);
        mean_act_targ = mean(act_targ_vector);
        std_rest_targ = std(rest_targ_vector);
        std_act_targ = std(act_targ_vector);
        sem_rest_targ = std(rest_targ_vector)/sqrt(length(rest_targ_vector));
        sem_act_targ = std(act_targ_vector)/sqrt(length(act_targ_vector));
        if ~isempty(deact_targ_vector)
            mean_deact_targ = mean(deact_targ_vector);
            std_deact_targ = std(deact_targ_vector);
            sem_deact_targ = std(deact_targ_vector)/sqrt(length(deact_targ_vector));
        end
        if bg_found
            mean_rest_bg = mean(rest_bg_vector);
            mean_act_bg = mean(act_bg_vector);
            std_rest_bg = std(rest_bg_vector);
            std_act_bg = std(act_bg_vector);
            sem_rest_bg = std(rest_bg_vector)/sqrt(length(rest_bg_vector));
            sem_act_bg = std(act_bg_vector)/sqrt(length(act_bg_vector));
            if ~isempty(deact_bg_vector)
                mean_deact_bg = mean(deact_bg_vector);
                std_deact_bg = std(deact_bg_vector);
                sem_deact_bg = std(deact_bg_vector)/sqrt(length(deact_bg_vector));
            end
            mean_rest_diff = mean(rest_diff_vector);
            mean_act_diff = mean(act_diff_vector);
            std_rest_diff = std(rest_diff_vector);
            std_act_diff = std(act_diff_vector);
            sem_rest_diff = std(rest_diff_vector)/sqrt(length(rest_diff_vector));
            sem_act_diff = std(act_diff_vector)/sqrt(length(act_diff_vector));
            if ~isempty(deact_diff_vector)
                mean_deact_diff = mean(deact_diff_vector);
                std_deact_diff = std(deact_diff_vector);
                sem_deact_diff = std(deact_diff_vector)/sqrt(length(deact_diff_vector));
            end
        end
        
        % add descriptive stats to results structure
        result.descriptives = {'Target Rest Mean'; 'Target Rest SD';...
            'Target Rest SEM'; 'Target Act Mean'; 'Target Act SD';...
            'Target Act SEM'};
        result.descriptives(1,2) = num2cell(mean_rest_targ);
        result.descriptives(2,2) = num2cell(std_rest_targ);
        result.descriptives(3,2) = num2cell(sem_rest_targ);
        result.descriptives(4,2) = num2cell(mean_act_targ);
        result.descriptives(5,2) = num2cell(std_act_targ);
        result.descriptives(6,2) = num2cell(sem_act_targ);
        
        if ~isempty(deact_targ_vector)
            result.descriptives(7:9,1) = {'Target Deact Mean'; 'Target Deact SD';...
                'Target Deact SEM'};
            result.descriptives(7,2) = num2cell(mean_deact_targ);
            result.descriptives(8,2) = num2cell(std_deact_targ);
            result.descriptives(9,2) = num2cell(sem_deact_targ);
        end
        if bg_found
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Bg Rest Mean'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(mean_rest_bg);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Bg Rest SD'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(std_rest_bg);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Bg Rest SEM'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(sem_rest_bg);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Bg Act Mean'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(mean_act_bg);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Bg Act SD'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(std_act_bg);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Bg Act SEM'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(sem_act_bg);
            if ~isempty(deact_bg_vector)
                result.descriptives(size(result.descriptives,1)+1,1) = ...
                    {'Bg Deact Mean'};
                result.descriptives(size(result.descriptives,1),2) = ...
                    num2cell(mean_deact_bg);
                result.descriptives(size(result.descriptives,1)+1,1) = ...
                    {'Bg Deact SD'};
                result.descriptives(size(result.descriptives,1),2) = ...
                    num2cell(std_deact_bg);
                result.descriptives(size(result.descriptives,1)+1,1) = ...
                    {'Bg Deact SEM'};
                result.descriptives(size(result.descriptives,1),2) = ...
                    num2cell(sem_deact_bg);
            end
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Diff Rest Mean'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(mean_rest_diff);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Diff Rest SD'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(std_rest_diff);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Diff Rest SEM'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(sem_rest_diff);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Diff Act Mean'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(mean_act_diff);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Diff Act SD'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(std_act_diff);
            result.descriptives(size(result.descriptives,1)+1,1) = ...
                {'Diff Act SEM'};
            result.descriptives(size(result.descriptives,1),2) = ...
                num2cell(sem_act_diff);
            if ~isempty(deact_diff_vector)
                result.descriptives(size(result.descriptives,1)+1,1) = ...
                    {'Diff Deact Mean'};
                result.descriptives(size(result.descriptives,1),2) = ...
                    num2cell(mean_deact_diff);
                result.descriptives(size(result.descriptives,1)+1,1) = ...
                    {'Diff Deact SD'};
                result.descriptives(size(result.descriptives,1),2) = ...
                    num2cell(std_deact_diff);
                result.descriptives(size(result.descriptives,1)+1,1) = ...
                    {'Diff Deact SEM'};
                result.descriptives(size(result.descriptives,1),2) = ...
                    num2cell(sem_deact_diff);
            end
        end
        
        % calculate inferential stats (simple repeated-measures t-tests of rest
        % vs. active and, if applicable, rest vs. deactive / active vs.
        % deactive)
        [h,sig,ci,stats] = ttest2(act_targ_vector,rest_targ_vector);
        result.inferential.target_ttest = {'T (Act-Rest)'; 'df'; 'p'};
        result.inferential.target_ttest(1,2) = num2cell(stats.tstat);
        result.inferential.target_ttest(2,2) = num2cell(stats.df);
        result.inferential.target_ttest(3,2) = num2cell(sig);
        if ~isempty(deact_targ_vector)
            [h,sig,ci,stats] = ttest2(deact_targ_vector,rest_targ_vector);
            result.inferential.target_ttest(4:6,1) = {'T (Deact-Rest)'; 'df'; 'p'};
            result.inferential.target_ttest(4,2) = num2cell(stats.tstat);
            result.inferential.target_ttest(5,2) = num2cell(stats.df);
            result.inferential.target_ttest(6,2) = num2cell(sig);
            [h,sig,ci,stats] = ttest2(act_targ_vector,deact_targ_vector);
            result.inferential.target_ttest(7:9,1) = {'T (Act - Deact)'; 'df'; 'p'};
            result.inferential.target_ttest(7,2) = num2cell(stats.tstat);
            result.inferential.target_ttest(8,2) = num2cell(stats.df);
            result.inferential.target_ttest(9,2) = num2cell(sig);
        end
        if bg_found
            [h,sig,ci,stats] = ttest2(act_bg_vector,rest_bg_vector);
            result.inferential.bg_ttest = {'T (Act-Rest)'; 'df'; 'p'};
            result.inferential.bg_ttest(1,2) = num2cell(stats.tstat);
            result.inferential.bg_ttest(2,2) = num2cell(stats.df);
            result.inferential.bg_ttest(3,2) = num2cell(sig);
            if ~isempty(deact_bg_vector)
                [h,sig,ci,stats] = ttest2(deact_bg_vector,rest_bg_vector);
                result.inferential.bg_ttest(4:6,1) = {'T (Deact-Rest)'; 'df'; 'p'};
                result.inferential.bg_ttest(4,2) = num2cell(stats.tstat);
                result.inferential.bg_ttest(5,2) = num2cell(stats.df);
                result.inferential.bg_ttest(6,2) = num2cell(sig);
                [h,sig,ci,stats] = ttest2(act_bg_vector,deact_bg_vector);
                result.inferential.bg_ttest(7:9,1) = {'T (Act - Deact)'; 'df'; 'p'};
                result.inferential.bg_ttest(7,2) = num2cell(stats.tstat);
                result.inferential.bg_ttest(8,2) = num2cell(stats.df);
                result.inferential.bg_ttest(9,2) = num2cell(sig);
            end
            
            [h,sig,ci,stats] = ttest2(act_diff_vector,rest_diff_vector);
            result.inferential.diff_ttest = {'T (Act-Rest)'; 'df'; 'p'};
            result.inferential.diff_ttest(1,2) = num2cell(stats.tstat);
            result.inferential.diff_ttest(2,2) = num2cell(stats.df);
            result.inferential.diff_ttest(3,2) = num2cell(sig);
            if ~isempty(deact_diff_vector)
                [h,sig,ci,stats] = ttest2(deact_diff_vector,rest_diff_vector);
                result.inferential.diff_ttest(4:6,1) = {'T (Deact-Rest)'; 'df'; 'p'};
                result.inferential.diff_ttest(4,2) = num2cell(stats.tstat);
                result.inferential.diff_ttest(5,2) = num2cell(stats.df);
                result.inferential.diff_ttest(6,2) = num2cell(sig);
                [h,sig,ci,stats] = ttest2(act_diff_vector,deact_diff_vector);
                result.inferential.diff_ttest(7:9,1) = {'T (Act - Deact)'; 'df'; 'p'};
                result.inferential.diff_ttest(7,2) = num2cell(stats.tstat);
                result.inferential.diff_ttest(8,2) = num2cell(stats.df);
                result.inferential.diff_ttest(9,2) = num2cell(sig);
            end
        end
        
        % calulate inferential stats (GLM)
		HRF_Fit=-1; n0 = 7;
        moco = params.reference.moco_par;
        moco = moco - repmat(mean(moco),[size(moco,1),1]);
        ref = horzcat(params.reference.X, moco);
        for i = 1:size(ref,2)
            ref(:,i) = mpi_BandPassFilterTimeSeries(ref(:,i), tr, f_low, f_high)+mean(ref(:,i));
        end
        out = roi_glm(mean_targ_filt(n0:end), ref(n0:end,:),'TR',tr,'fit',HRF_Fit);
        result.inferential.target_GLM(1:4,1) = {'delay'; 'beta'; 't'; 'PSC'};
        result.inferential.target_GLM(1:4,2) = {out.stat.delay; out.stat.beta; out.stat.t; out.stat.PSC};
        if bg_found
            out = roi_glm(mean_bg_filt(n0:end), ref(n0:end,:),'TR',tr,'fit', HRF_Fit);
            result.inferential.bg_GLM(1:4,1) = {'delay'; 'beta'; 't'; 'PSC'};
            result.inferential.bg_GLM(1:4,2) = {out.stat.delay; out.stat.beta; out.stat.t; out.stat.PSC};
            out = roi_glm(mean_diff_filt(n0:end), ref(n0:end,:),'TR',tr,'fit', HRF_Fit);
            result.inferential.diff_GLM(1:4,1) = {'delay'; 'beta'; 't'; 'PSC'};
            result.inferential.diff_GLM(1:4,2) = {out.stat.delay; out.stat.beta; out.stat.t; out.stat.PSC};
        end
        
        timeseries = out.plot.pred'; 
        timeseries(2,:) = out.plot.data'; 
        h = plot_timecourse(timepoints(7:end),timeseries,{'GLM' 'Data'},ref_noshift(7:end),roi_name);
        fig_save = fullfile(out_dir,'roi_GLM.fig');
        saveas(h,fig_save);
        close(h);
        
        % remove mean
        mean_act_targ = mean_act_targ - mean(mean_targ);
        mean_rest_targ = mean_rest_targ - mean(mean_targ);
        if ~isempty(deact_targ_vector)
            mean_deact_targ = mean_deact_targ - mean(mean_targ);
        end
        if bg_found
            mean_act_bg = mean_act_bg - mean(mean_bg);
            mean_rest_bg = mean_rest_bg - mean(mean_bg);
            if ~isempty(deact_targ_vector)
                mean_deact_bg = mean_deact_bg - mean(mean_bg);
            end
            mean_act_diff = mean_act_diff - mean(mean_diff);
            mean_rest_diff = mean_rest_diff - mean(mean_diff);
            if ~isempty(deact_diff_vector)
                mean_deact_diff = mean_deact_diff - mean(mean_diff);
            end
        end
        
        % plot bar charts with error bars for target (and background)
        if ~isempty(deact_targ_vector)
            targ_bar = nfb_errorbar([mean_act_targ; mean_deact_targ; ...
                mean_rest_targ],[sem_act_targ; sem_deact_targ; sem_rest_targ],...
                'Labels',{'Active' 'Deactive' 'Rest'},'Title',roi_name,...
                'YLabel','Normalized Signal Intensity (demeaned)');
        else
            targ_bar = nfb_errorbar([mean_act_targ; mean_rest_targ],...
                [sem_act_targ; sem_rest_targ],'Labels',{'Active' 'Rest'},...
                'Title',roi_name,'YLabel','Normalized Signal Intensity (demeaned)');
        end
        fig_save = fullfile(out_dir,'target_errorbar.fig');
        saveas(targ_bar,fig_save);
        close(targ_bar);
        
        if bg_found
            if ~isempty(deact_targ_vector)
                targ_bg_bar = nfb_errorbar(...
                    [mean_act_targ; mean_act_bg; mean_deact_targ; mean_deact_bg; mean_rest_targ; mean_rest_bg],...
                    [sem_act_targ; sem_act_bg; sem_deact_targ; sem_deact_bg; sem_rest_targ; sem_rest_bg],...
                    'Labels',{'Targ Active' 'Bg Active' 'Targ Deactive' 'Bg Deactive' 'Targ Rest' 'Bg Rest'},'Title',roi_name,...
                    'YLabel','Normalized Signal Intensity (demeaned)');
            else
                targ_bg_bar = nfb_errorbar([mean_act_targ mean_act_bg; ...
                    mean_rest_targ mean_rest_bg],[sem_act_targ sem_act_bg; ...
                    sem_rest_targ sem_rest_bg],'Labels',{'Targ Active' ...
                    'Bg Active' 'Targ Rest' 'Bg Rest'},'Title',[roi_name ' / Bg'],...
                    'YLabel','Normalized Signal Intensity (demeaned)');
            end
            fig_save = fullfile(out_dir,'target_background_errorbar.fig');
            saveas(targ_bg_bar,fig_save);
            close(targ_bg_bar);
            
            if ~isempty(deact_targ_vector)
                diff_bar = nfb_errorbar([mean_act_diff; mean_deact_diff; ...
                    mean_rest_diff],[sem_act_diff; sem_deact_diff; sem_rest_diff],...
                    'Labels',{'Active' 'Deactive' 'Rest'},'Title',[roi_name ' - Background'],...
                    'YLabel','Normalized Intensity Difference (demeaned)');
            else
                diff_bar = nfb_errorbar([mean_act_diff; ...
                    mean_rest_diff],[sem_act_diff; ...
                    sem_rest_diff],'Labels',{'Diff Active' ...
                    'Diff Rest'},'Title',[roi_name ' - Background'],...
                    'YLabel','Normalized Intensity Difference (demeaned)');
            end
            fig_save = fullfile(out_dir,'difference_errorbar.fig');
            saveas(diff_bar,fig_save);
            close(diff_bar);
        end
        
        if strcmp(varargin{1},'offline')
            if nargin == 5
                % Motion Parameter file has been specified
                moco_file = varargin{5};
                result.moco.info(1,1) = cellstr('MoCo Values');
                result.moco.info(1,2) = cellstr(moco_file);
                fid = fopen(moco_file,'r');
                moco = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f',...
                    'HeaderLines',6);
                fclose(fid);
                result.moco.cc(1:6,1) = {'targ cc'; 'targ p'; 'bg cc'; 'bg p';...
                    'diff cc'; 'diff p'};
                for n = 1:12
                    moco_vector = detrend(moco{n});
                    [cc, p] = corrcoef(mean_targ,moco_vector);
                    result.moco.cc(1,n+1) = num2cell(cc(2,1));
                    result.moco.cc(2,n+1) = num2cell(p(2,1));
                    if p(2,1) < 0.05
                        fprintf('Warning! Significant correlation between signal intensity in target ROI and MoCo parameter in column %s\n',...
                            int2str(n));
                        fprintf('cc = %f\tp = %f\n',cc(2,1),p(2,1));
                    end
                    [cc, p] = corrcoef(mean_bg,moco_vector);
                    result.moco.cc(3,n+1) = num2cell(cc(2,1));
                    result.moco.cc(4,n+1) = num2cell(p(2,1));
                    if p(2,1) < 0.05
                        fprintf('Warning! Significant correlation between signal intensity in background ROI and MoCo parameter in column %s\n',...
                            int2str(n));
                        fprintf('cc = %f\tp = %f\n',cc(2,1),p(2,1));
                    end
                    [cc, p] = corrcoef(mean_diff,moco_vector);
                    result.moco.cc(5,n+1) = num2cell(cc(2,1));
                    result.moco.cc(6,n+1) = num2cell(p(2,1));
                    if p(2,1) < 0.05
                        fprintf('Warning! Significant correlation between signal intensity difference and MoCo parameter in column %s\n',...
                            int2str(n));
                        fprintf('cc = %f\tp = %f\n',cc(2,1),p(2,1));
                    end
                end
            end
        end
        
        if strcmp(varargin{1},'offline')
            mat_save = fullfile(out_dir,'results.mat');
            save(mat_save,'result');
        end
    otherwise
        fprintf('%s is not a recognized option for input 1.\n',varargin{1});
        help nfb_analyzer
end
end

function h = plot_timecourse(timepoints,timeseries,leg,ref_noshift,roi_name)
mean_targ_filt = timeseries(1,:); bg_found = false;
if size(timeseries,1) > 1
    bg_found = true;
    mean_bg_filt = timeseries(2,:);
end
if isempty(leg), leg = {'Target' 'Background'}; end

h = figure; hold on
plot(timepoints,mean_targ_filt,'-k','LineWidth',2.5);
if bg_found
    plot(timepoints,mean_bg_filt,':k','LineWidth',2.5);
end
ylims = get(gca,'YLim');
clf; hold on;
warning off MATLAB:divideByZero;
pos_active_vector = (double(ref_noshift == 1)*ylims(2)./double(ref_noshift == 1))';
neg_active_vector = (double(ref_noshift == 1)*ylims(1)./double(ref_noshift == 1))';
pos_deactive_vector = (double(ref_noshift == -1)*ylims(2)./double(ref_noshift == -1))';
neg_deactive_vector = (double(ref_noshift == -1)*ylims(1)./double(ref_noshift == -1))';
warning on MATLAB:divideByZero;
if any(pos_active_vector) || any(neg_active_vector)
    bar(timepoints,pos_active_vector,1,'r','EdgeColor','none','ShowBaseLine','off','DisplayName','Upregulate');
    hBar = bar(timepoints,neg_active_vector,1,'r','EdgeColor','none','ShowBaseLine','off');
    set(get(get(hBar,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
if any(pos_deactive_vector) || any(neg_deactive_vector)
    bar(timepoints,pos_deactive_vector,1,'b','EdgeColor','none','ShowBaseLine','off','DisplayName','Downregulate');
    hBar = bar(timepoints,neg_deactive_vector,1,'b','EdgeColor','none','ShowBaseLine','off');
    set(get(get(hBar,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
plot(timepoints,mean_targ_filt,'-k','LineWidth',2.5,'DisplayName',leg{1});
if bg_found
    plot(timepoints,mean_bg_filt,':k','LineWidth',2.5,'DisplayName',leg{2});
end
legend('show','Location','BestOutside');
axis([1 length(timepoints) ylims(1) ylims(2)]);
t = title([roi_name ' timecourse']);
set(t,'Interpreter','none');
xlabel('Time / Images');
ylabel('Signal Intensity (demeaned)');
drawnow
hold off
end