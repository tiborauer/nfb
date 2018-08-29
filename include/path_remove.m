function path_remove

global params;
req = params.path.req;
mod = params.path.mod;

try
    for i = 1:numel(req)
        if mod(i)
            rmpath(req{i});
        end
    end
catch
    warning('Error occured during path removal!\nCheck cleaning process!');
end
end