function nfb_close(varargin)
% User-defined GUI close request function

for i = 1:nargin
    if islogical(varargin{i}), toConfirm = varargin{i}; end
    if isstruct(varargin{i}), toClose = varargin{i}; end
    if ischar(varargin{i}), msg = varargin{i}; end
end
if ~exist('toConfirm','var'), toConfirm = true; end
if ~exist('toClose','var'), toClose.all = true; end
if ~exist('msg','var'), msg = 'Closing...'; end

% to display a question dialog box
if toConfirm 
    selection = questdlg('This will close NFB Toolbox. Are you sure?',...
        'Close Request',...
        'Yes','No','Yes');
    if strcmp(selection,'Yes')
        doClose(msg,toClose);
    end
else
    doClose(msg,toClose);
end
end

function doClose(msg,toClose)
global params;

if isstruct(params) && isfield(params,'files')
    save(fullfile(fileparts(params.files.logfile),'params.mat'),'params');
end

fprintf('\n%s\n',msg);
pause(1);
try
    % GUI
    if ~isfield(toClose,'GUI') || toClose.GUI
        h = findobj('Name', 'Neurofeedback Status Window'); if ~isempty(h), delete(h); end;
        h = findobj('Name', 'Feedback Level'); if ~isempty(h), delete(h); end;
        h = findobj('Name', 'Experiment Info'); if ~isempty(h), delete(h); end;
    end
    
    % TCP - watch
    if ~isfield(toClose,'TCP') || toClose.TCP
        if isstruct(params) && isstruct(params.data.watch)
            pnet(params.data.watch.sock,'close');
            pnet(params.data.watch.con,'close');
        end
    end
    
    % UDP - out
    if ~isfield(toClose,'UDP') || toClose.UDP
        if isstruct(params) && isstruct(params.data.out)
            pnet(params.data.out.udp,'close');
        end
    end
        
    % files
    diary off;
    if ~isfield(toClose,'files') || toClose.files
        if isstruct(params), delete(params.files.logfile); end
    end
catch
end
% reset environment
if isstruct(params)
    fprintf('NFB Toolbox closed on %s. It has run for %6.3f seconds\n',...
        datestr(clock),etime(clock,params.clocks.rt));
    path_remove;
    cd(params.path.start_dir);
    for w = 1:numel(params.warnings)
        warning(params.warnings(w));
    end
    clear global params CANCEL PAUSE NFB_ROOTDIR NFB_VER ROI ROI_CHNG;
else
    clear global params;
end
end