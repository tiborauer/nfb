% draw the figures for the neurofeedback experiment (graph window, status
% window and feedback slider)
% in1 ... configuration structure
% outputs ... figure handles
% 
% this file written by 
% Henry Luetcke (hluetck@gwdg.de) and
% Tibor Auer (Tibor.auer@mrc-cbu.cam.ac.uk)

function varargout = nfb_figurecreate(in1)

rtconfig = in1;

% multiple roi - create a cell array of the names of targ roi(s), and pass
% it to fb_control
global params ROI;
nr = numel(ROI);
mvpc = rtconfig.reference.mv_MVPC;
for ir = 1:nr
    targ_str{ir} = rtconfig.data.(['targ_roi' num2str(ir)]);
    [p targ_roi{ir}] = fileparts(targ_str{ir});
end
figure(1);set(1,'Units','pixels','OuterPosition',[1 1 1600 1200]);
scr_pos=get(1,'OuterPosition');
close(1);
SPC = round(scr_pos(3)/400);

ts_fig.fb_control = gui_feedback_slider(rtconfig.feedback, targ_roi, mvpc);
set(ts_fig.fb_control,'Name','Feedback Level');
set(ts_fig.fb_control,'Units','pixels');
fb_pos = get(ts_fig.fb_control,'OuterPosition');
set(ts_fig.fb_control,'OuterPosition',[SPC scr_pos(4)+scr_pos(2)-fb_pos(4)-SPC 0.33*(scr_pos(3)-3*SPC) fb_pos(4)]);
fb_pos = get(ts_fig.fb_control, 'OuterPosition');

ts_fig.info_fig = gui_expinfo(rtconfig);
set(ts_fig.info_fig,'Units','pixels','OuterPosition',...
    [fb_pos(1) scr_pos(2)+SPC fb_pos(3) scr_pos(4)-3*SPC-fb_pos(4)]);

if ~strcmp(rtconfig.misc.plot_type,'no')
    ts_fig.main = figure('Units','pixels','OuterPosition',...
        [2*SPC+fb_pos(3) scr_pos(2)+SPC scr_pos(3)-3*SPC-fb_pos(3) scr_pos(4)-2*SPC],...
        'CloseRequestFcn',@nfb_close);
    set(ts_fig.main,'Name','Neurofeedback Status Window','NumberTitle','off');
    ts_fig.axes = axes;
    hold on;            

    % assigning colors to each roi red, blue and black are not allowed 
    % because they are the colors of the bars and the measured data
    ts_fig.colors = [
        0 1 0;...% green
        0.75 0.75 0;...% dark yellow
        1 0 1;...% magenta
        0 1 1;...% cyan
        0.5 0.5 0.5;...% gray
        0.5 0 1;...% dark red
        1 0.62 0.4;...% copper
        0.49 1 0.83;...% aquamarine
        0 0.5 0;];% dark green

    % initial variables
    timepoints = rtconfig.timing.timepoints;
    raw_plot = strcmp(rtconfig.misc.plot_type,'raw');
    yd(1:timepoints) = NaN;
    active_vector = params.reference.real.active'; 
    deactive_vector = params.reference.real.deactive'; 
    
    % bars
    ts_fig.bar_act1 = bar(1:timepoints,active_vector,1,'r','EdgeColor','none',...
        'ShowBaseLine','off');
    set(ts_fig.bar_act1, 'UserData', active_vector);
    ts_fig.bar_act2 = bar(1:timepoints,active_vector,1,'r','EdgeColor','none',...
        'ShowBaseLine','off');
    set(ts_fig.bar_act2, 'UserData', active_vector);
    hAnn = get(ts_fig.bar_act2,'Annotation');
    hLeg = get(hAnn','LegendInformation');
    set(hLeg,'IconDisplayStyle','off')
    ts_fig.bar_deact1 = bar(1:timepoints,deactive_vector,1,'b','EdgeColor','none',...
        'ShowBaseLine','off');
    set(ts_fig.bar_deact1, 'UserData', deactive_vector);
    ts_fig.bar_deact2 = bar(1:timepoints,deactive_vector,1,'b','EdgeColor','none',...
        'ShowBaseLine','off');
    set(ts_fig.bar_deact2, 'UserData', deactive_vector);
    hAnn = get(ts_fig.bar_deact2,'Annotation');
    hLeg = get(hAnn','LegendInformation');
    set(hLeg,'IconDisplayStyle','off')

    % labels
    DIST = 2*((max(-rtconfig.feedback.max_neg,rtconfig.feedback.max_pos))+1);  % distance between plots (even number only) = 2*(max_deviation+1)
    for ir = 1:nr
        ts_fig.(['p' int2str(ir)]) = plot(1:timepoints,yd,'-','LineWidth',1.5,'Color', ts_fig.colors(ir,:));
        if mvpc
            ytl{ir} = ['MVPC'];
        elseif raw_plot
            ytl{ir} = ['Roi - ' targ_roi{ir}];
        else
            ytl{ir} = ['Difference' num2str(ir)];
        end
        yt(ir) = ir*DIST;
    end
    ts_fig.(['p' int2str(nr+1)]) = plot(1:timepoints,yd,'LineWidth',3.5,...
        'Color',nfb_combine(ts_fig.colors(1:nr,:),abs(ROI)));
    ytl{nr+1} = 'Measured';
    yt(nr+1) = (nr+1)*DIST;
    ts_fig.np = nr+1; % number of plots
    if raw_plot && ~isempty(rtconfig.data.bg_roi)
        ts_fig.(['p' int2str(nr+2)]) = plot(1:timepoints,yd,':k','LineWidth',1.5);
        ytl{nr+2} = 'Background';
        yt(nr+2) = (nr+2)*DIST;
        ts_fig.np = nr+2; % number of plots
    end
    
    xlabel('Time/Scans');
    
    STEP = round(rtconfig.timing.volumes/100)*5;    
    set(ts_fig.axes, 'XLim', [1, timepoints]);  
    set(ts_fig.axes, 'XTick', 4*rtconfig.timing.ndt+1:STEP*rtconfig.timing.ndt:timepoints); 
    set(ts_fig.axes, 'XTickLabel', 5:STEP:rtconfig.timing.volumes); 
    
    ylabel('Normalized Percent Signal');
    for i = 1:numel(ytl)
        YT((i-1)*(DIST-1)+1:i*(DIST-1)) = i-1+((i-1)*(DIST-1)+1:i*(DIST-1))+DIST/2;
        YTL{i*(DIST-1)-(DIST/2-1)} = ytl{i};
        for j = 1:DIST/2-1
            YTL{i*(DIST-1)-(DIST/2-1)-j} = num2str(-j);
            YTL{i*(DIST-1)-(DIST/2-1)+j} = num2str(j);
        end
    end
    set(ts_fig.axes, 'YTick', YT);
    set(ts_fig.axes, 'YTickLabel', YTL');
    ts_fig.dist = DIST;

    % normalization
    norm_vector = double(params.reference.real.norm'); norm_vector(~norm_vector) = nan;
    ts_fig.norm_plot = plot(1:timepoints,norm_vector,'-g','LineWidth',2.5);
    set(ts_fig.norm_plot, 'UserData', norm_vector);

    hold off;
else
    ts_fig = 0;
end

varargout{1} = ts_fig;
varargout{2} = targ_roi; % name of ROIS