% slope function with "sigmoid" possibility
% slope is devided into the middle part where the changes in steps are
% fast/normal and the extremites where the changes are slower
% the ratio of one extremity to the whole slope is hard-coded (SL_DEG)
% val ... value (percental change)
% deg ... how many degree we have
% p_min, p_max ... values corresponding to the two extremity (percental change)
% sd ... value corresponding to the break in the steps (percental change)
function res = slope_fun(val, deg, p_min, p_max, br_l, br_h, sl_mid, sl_ext)
if val >= p_max
    res = deg;
elseif val <= p_min
    res = 1;
else
    if nargin > 4
        gr_mid = (deg-1)*sl_mid/(2*br_l);
        gr_fast = (deg-1)*(0.5-sl_ext-0.5*sl_mid)/(br_h-br_l);
        gr_slow_d = (deg-1)*sl_ext/(-br_h-p_min);
        gr_slow_a = (deg-1)*sl_ext/(p_max-br_h);
        if abs(val) < br_l % middle part
            res = round(val*gr_mid + 1 + (deg-1)*0.5);
        elseif abs(val) < br_h % moderate (de)active
            if val>0
                res = round((val-br_l)*gr_fast + 1 + (deg-1)*(0.5 + 0.5*sl_mid));
            else
                res = round((val+br_h)*gr_fast + 1 + (deg-1)*(sl_ext));
            end
        else % extreme (de)active
            if val>0
                res = round((val-br_h)*gr_slow_a + 1 + (deg-1)*(1-sl_ext));
            else
                res = round((val-p_min)*gr_slow_d + 1);
            end
        end
    else
        gr = (deg-1)/(p_max - p_min);
        res = round((val-p_min)*gr + 1);
    end
end