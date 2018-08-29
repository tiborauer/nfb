function out = cell_insert(in,line,n)
if ~iscell(line), line = {line}; end
if numel(n) < 2
    out = insert1D(in,line,n);
else
    out = in;
    out1 = insert1D({in{n(1),:}},line,n(2));
    out{1,end+1:end+numel(line)} = [];
    for i = 1:size(out,2)
        out{n(1),i} = out1{i};
    end
end

function out = insert1D(in,line,n)
out = {};
for i = 1:n-1
    out{i} = in{i};
end
for i = 1:numel(line)
    out{end+1} = line{i};
end
for i = n:numel(in)
    out{end+1} = in{i};
end
if (sum(size(out) >= size(in)) ~= 2), out = out'; end 