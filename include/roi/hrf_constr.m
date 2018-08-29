function [c ceq] = hrf_constr(p)
%   p(1) - delay of response (relative to onset)     6           1  10
%   p(2) - delay of undershoot (relative to onset)  16     (p1+p3)  20
%   p(3) - dispersion of response                    1           1  no
%   p(4) - dispersion of undershoot                  1           1   5
%   p(5) - ratio of response to undershoot           6           1  10
%   p(6) - length of kernel (seconds)               32  (p2+p3+p4)  40
c = [
    -p(1)+1;
    p(1)-10
    -p(2)+p(1)+p(3);
    p(2)-20
    -p(3)+1;
    -p(4)+1;
    p(4)-5
    -p(5)+1
    p(5)-10
    -p(6)+p(2)+p(3)+p(4);
    p(6)-40   
    ];
ceq = [];