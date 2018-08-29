function path_add

global params;
req = params.path.req;
if isfield(params.path, 'mod')
    mod = params.path.mod;
else
    mod = false(1,numel(req));
end

p = path;
if isunix
    sep = ':';
else
    sep = ';';
end

for i = 1:numel(req)
    if isempty(strfind(p,[req{i} sep]))
        addpath(req{i});
        mod(i) = true;
    end
end

params.path.mod = mod;
end