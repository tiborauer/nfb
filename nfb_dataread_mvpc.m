function [result norm_par] = nfb_dataread_mvpc(result, rtconfig, targ_data, bg_data, n, norm_par)

global MAX_POS MAX_NEG;

result.ts(n,3) = mean(targ_data);
result.ts(n,4) = mean(bg_data);

eval(struct_extract(norm_par));
% Normalization: based on the most recent rest period
% normalization in the baseline period
if result.ts(n,2) == 11
    % normalize
    targ_vect(end+1,:) = targ_data;
    if ~isempty(rtconfig.data.bg_roi)
        bg_vect(end+1,:) = bg_data;
    end
else
    % do not normalize
    if ~isempty(targ_vect)
        % finish normalization
        targ_base = mean(targ_vect);
        if ~isempty(rtconfig.data.bg_roi)
            bg_base = mean(bg_vect);
        end
        targ_vect = [];
        bg_vect = [];
    end
end

norm_par = struct_update(norm_par, targ_vect, bg_vect, targ_base, bg_base);

if targ_base(1)
    mvpc = rtconfig.reference.mv_Train;
    if mvpc.cfg.Perc
        data_test = perc_data(double(targ_data), 0, targ_base);
        bg_test = perc_data(double(bg_data), 0, bg_base);
    else
        data_test = double(targ_data);
        bg_test = double(bg_data);
    end

    result.ts(n,7) = mean(data_test);
    result.ts(n,8) = mean(bg_test);
    
    switch mvpc.cfg.Bg
        case 1
            data_test = data_test-mean(bg_test);
        case 2
            data_test = [data_test; bg_test];
    end
    if strcmp(mvpc.cfg.Method,'NN')
        r = sim(mvpc.model.net, data_test);
        result.ts(n,9) = r(end);
    elseif strcmp(mvpc.cfg.Method,'SVM')
        [e, r] = svmclassify(data_test', 0, mvpc.model);
        r = detrend([result.ts(:,9); r]);
        if (abs(r(end)) > 1)
            result.ts(n,9) = (r(end)/abs(r(end))+1)/2; 
        else
            result.ts(n,9) = (r(end)+1)/2;
        end
    end

    result.ts(n,5) = result.ts(n,9);

    if rtconfig.feedback.break_yn
        % parameters of breakpoints
        br_l = rtconfig.feedback.break_low;
        br_h = rtconfig.feedback.break_high;
        sl_mid = rtconfig.feedback.sl_middle;
        sl_ext = rtconfig.feedback.sl_extremity;
        result.ts(n,10)= slope_fun(result.ts(n,9), 21, MAX_NEG, MAX_POS, br_l, br_h, sl_mid, sl_ext);
    else
        result.ts(n,10)= slope_fun(result.ts(n,9), 21, MAX_NEG, MAX_POS);
    end
end