function out = nfb_combine(in1, in2)
if find(size(in2) == 1) ~= 2
    in2 = in2';
end
if size(in1,2) ~= size(in2,1)
    in1 = in1';
end
out = in1*in2./sum(abs(in2));



