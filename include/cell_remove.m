function out = cell_remove(in,n)
if numel(n) < 2
    out = remove1D(in,n);
else
    out = in;
    out1 = remove1D({in{n(1),:}},n(2));
    out1{end+1} = [];
    for i = 1:size(out,2)
        out{n(1),i} = out1{i};
    end
end

function out = remove1D(in,n)
out = {};
for i = 1:n-1
    out{i} = in{i};
end
for i = n+1:numel(in)
    out{end+1} = in{i};
end
if (sum(size(out) >= size(in)) ~= 2), out = out'; end 