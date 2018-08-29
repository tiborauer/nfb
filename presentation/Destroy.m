function Destroy(ME)
global params;

Screen('CloseAll');
if isfield(params,'resp'), fclose(params.resp); end
if isfield(params,'pulse') && ~params.pulse.emul, delete(params.pulse.io); end
if isfield(params, 'file') && isfield(params.file,'logfid'), fclose(params.file.logfid);end

if nargin
    fprintf('\nERROR in %s:\n  line %d: %s\n',ME.stack.file, ME.stack.line, ME.message);
    if isfield(params.file,'roi')
        if exist(params.file.roi,'file'), delete(params.file.roi);end
    end
    if isfield(params.file,'log'),
        if exist(params.file.log,'file'), delete(params.file.log);end
    end
end

clear global params;