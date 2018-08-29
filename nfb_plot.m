% nfb_plot is the plotting function of the Neurofeedback toolbox
% depending on settings in the config structure, it plots the (filtered)
% raw signal intensities in target and background ROI or the difference
% between the two
%
% USAGE:
%
% function [out1] = nfb_plot(in1,in2,in3,in4)
%
% in1 ... configuration structure
% in2 ... results structure
% in3 ... handle structure containing handles to plotting figure and the plots
% in4 ... current timepoint
% out1 ... handle structure containing handles to plotting figure and the plots

% this file written by 
% Henry Luetcke (hluetck@gwdg.de) and
% Tibor Auer (tauer@gwdg.de)

function [ts_fig] = nfb_plot(rtconfig,results,ts_fig,n)

global ROI ROI_CHNG;

if nargin ~= 4
    disp('You MUST provide 4 input argument');
    help nfb_plot
    return
end

%% ydata(:,1:nr) - target(s), ydata(:,nr+1) - measured, ydata(:,nr+2) - background
% new indices
plot_ind = (n-1)*rtconfig.timing.ndt+1:n*rtconfig.timing.ndt;

nr = numel(results);

axes(ts_fig.axes);

% obtain the previous data from the plots
for i = 1:ts_fig.np
    ydata(:,i) = get(ts_fig.(['p' int2str(i)]), 'YData');
end

% update ydata
ind = 5;
switch rtconfig.misc.plot_type
    case 'diff' % plot the difference
		ind2meas = 9;
        bg_plot = false;
    case 'raw' % plot target intensity
		ind2meas = 7;
        bg_plot = true;
end

for ir = 1:nr
	% select the ydata to plot
	ydata(plot_ind,ir) = (results(ir).ts(n,ind)-results(ir).internal.base)/results(ir).internal.base*100;
end

% calculating measured data (changing roi), colors of output (thermometer) and percent signal
for ir = 1:nr
    outres(ir) = results(ir).ts(n,10);
    meas(ir) = results(ir).ts(n,ind2meas);
    if ~isempty(rtconfig.data.bg_roi)
        perc_sig(ir) = results(ir).ts(n,9);
    else
        perc_sig(ir) = results(ir).ts(n,7);
    end
end
ydata(plot_ind,nr+1) = nfb_combine(meas,ROI);
outres = round(nfb_combine(outres,ROI));
perc_sig = nfb_combine(perc_sig,ROI);

title(sprintf('Timepoint: %s   Color: %s   Percent Signal: %s',...
    int2str(n),int2str(outres),num2str(perc_sig,3)),...
    'FontSize',16,'FontWeight','bold');

if bg_plot && ~isempty(rtconfig.data.bg_roi) 

    % plot background intensities can be taken from any results structure
    % but for the sake of compatibility with "one-roi-case" it is better to
    % take it from the first
	ydata(plot_ind,nr+2) = (results(1).ts(n,ind+1)-results(ir).internal.bgbase)/results(ir).internal.bgbase*100;
end

%% update plots
for i = 1:ts_fig.np
    ydata(plot_ind,i) = ydata(plot_ind,i)+ts_fig.dist*i;
    set(ts_fig.(['p' int2str(i)]), 'YData', ydata(:,i));
end

% change Meas color according to the ROI selection
if n > 1 && ~ROI_CHNG
    hold on;
    for ir = 1:nr
        col(ir,:) = get(ts_fig.(['p' int2str(ir)]), 'Color');
    end
    col = nfb_combine(col,abs(ROI));
    plot(plot_ind,ydata(plot_ind,nr+1),'LineWidth',3.5,'Color',col);
end

% rescale the axes (5 units for margin)
ymin = 0.95*min(ydata(:));
ymax = 1.05*max(ydata(:));
if ~ymin, ymin = -0.05; end
if ~ymax, ymax = 0.05; end
set(ts_fig.axes, 'Ylim', [ymin ymax]);
timepoints = rtconfig.timing.timepoints;
STEP = round(rtconfig.timing.volumes/100)*5;    
set(ts_fig.axes, 'XTick', 4*rtconfig.timing.ndt+1:STEP*rtconfig.timing.ndt:timepoints);
set(ts_fig.axes, 'XTickLabel', 5:STEP:rtconfig.timing.volumes);

% redraw objects
set(ts_fig.bar_act1, 'YData', get(ts_fig.bar_act1, 'UserData')*ymin);
set(ts_fig.bar_act2, 'YData', get(ts_fig.bar_act2, 'UserData')*ymax);
set(ts_fig.bar_deact1, 'YData', get(ts_fig.bar_deact1, 'UserData')*ymin);
set(ts_fig.bar_deact2, 'YData', get(ts_fig.bar_deact2, 'UserData')*ymax);
set(ts_fig.norm_plot, 'YData', get(ts_fig.norm_plot, 'UserData')*ymin);
% e.o.f