function [o, d] = conbool(b)
sa = false;
na = 0;
for i = 1:length(b)
    if b(i)
        if sa
            d(na) = d(na) + 1;
        else
            sa = true;
            na = na + 1;
            o(na) = i;
            d(na) = 1;
        end
    else
        sa = false;
    end
end
o = o';
d = d';
