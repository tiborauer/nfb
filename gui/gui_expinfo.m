function varargout = gui_expinfo(varargin)
% gui_expinfo M-file for gui_expinfo.fig
%      gui_expinfo, by itself, creates a new gui_expinfo or raises the existing
%      singleton*.
%
%      H = gui_expinfo returns the handle to a new gui_expinfo or the handle to
%      the existing singleton*.
%
%      gui_expinfo('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_expinfo.M with the given input arguments.
%
%      gui_expinfo('Property','Value',...) creates a new gui_expinfo or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_expinfo_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_expinfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_expinfo

% Last Modified by GUIDE v2.5 12-Oct-2009 11:15:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_expinfo_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_expinfo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_expinfo is made visible.
function gui_expinfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_expinfo (see VARARGIN)

global CANCEL PAUSE NFB_VER ROI;

% Choose default command line output for gui_expinfo
handles.output = hObject;

rtconfig = varargin{1};

% set up graph and status windows
nr = numel(ROI);
for ir = 1:nr
    targ_str{ir} = rtconfig.data.(['targ_roi' num2str(ir)]);
end
if rtconfig.data.flip_slice
    flip_string = 'on';
else
    flip_string = 'off';
end
if rtconfig.preprocess.lp_filter
    lp_string = 'on';
else
    lp_string = 'off';
end
switch rtconfig.preprocess.moco_yn
    case 1
        moco_string = 'McFLIRT';
        moco_ref = rtconfig.preprocess.moco_ref;
    case 2
        moco_string = 'SPM Realign';
        moco_ref = rtconfig.preprocess.moco_ref;
    otherwise
        moco_string = 'None';
        moco_ref = 'N/A';
end
if rtconfig.timing.simul
    iltime = sprintf('Delay: %s',num2str(rtconfig.timing.TR));
else
    iltime = sprintf('TR: %s',num2str(rtconfig.timing.TR));
end

il1 = {sprintf('Volumes: %s',int2str(rtconfig.timing.volumes)),'',...
iltime,'',...
sprintf('ROI Info: %s',rtconfig.data.outfile),'',...
sprintf('Watch Dir: %s',rtconfig.data.watch_dir),'',...
sprintf('Output Dir: %s',rtconfig.data.output_dir),'',...
sprintf('ROI Type: %s',rtconfig.data.roi_def),''};
for i = 1:nr
    il2{(i-1)*2+1} = sprintf('Targ ROI %s: %s',int2str(i),targ_str{i});
    il2{i*2} = '';
end
% some more fancy details for the log window
if ispc
    [status, os] = dos('echo %OS%');
    [status, user] = dos('echo %USERNAME%');
    [status, domain] = dos('echo %USERDOMAIN%');
    os_info = [deblank(user) ' on ' deblank(domain)...
        ' (' deblank(os) ')'];
elseif isunix
    [status, os] = unix('uname -s');
    [status, user] = unix('whoami');
    [status, domain] = unix('uname -n');
    os_info = [deblank(user) ' on ' deblank(domain)...
        ' (' deblank(os) ')'];
end
mvpc = '';
if ~rtconfig.reference.mv_MVPC, mvpc = 'not '; end
il3 = {sprintf('Bg ROI: %s',rtconfig.data.bg_roi),'',...
sprintf('Flip ROI Slices: %s',flip_string ),'',...
sprintf('MoCo: %s',moco_string),'',...
sprintf('MoCo Reference: %s',moco_ref),'',...
sprintf('Smooth: %s',int2str(rtconfig.preprocess.smooth)),'',...
sprintf('LP-Filter: %s',lp_string),'',...
sprintf('MVPC: %sactive',mvpc),'',...
sprintf('Started evaluation: %s',datestr(clock)),'',...
sprintf('OS Info: %s',os_info),'',...
sprintf('Enviroment: Neurofeedback Toolbox version %s on Matlab %s',NFB_VER,version)};
set(handles.info_text,'String',cat(2,il1, il2, il3));

CANCEL = 0;
PAUSE = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_expinfo wait for user response (see UIRESUME)
% uiwait(handles.exp_info);

% --- Outputs from this function are returned to the command line.
function varargout = gui_expinfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CANCEL;
button = questdlg('Do you really want to cancel the analysis?',...
    'Cancel?','Yes','No','No');
if strcmp(button,'Yes')
    CANCEL = 1;
    fprintf('\nUser requested termination at %s\n\n',datestr(clock,13));
end


% --- Executes on button press in pause_button.
function pause_button_Callback(hObject, eventdata, handles)
% hObject    handle to pause_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PAUSE;

if ~PAUSE
    PAUSE = 1;
    set(handles.pause_button,'String','Resume');
    fprintf('\nUser requested pause at %s\n\n',datestr(clock,13));
else
    PAUSE = 0;
    set(handles.pause_button,'String','Pause');
    fprintf('\nUser requested analysis resume at %s\n\n',datestr(clock,13));
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in emul_button.
function emul_button_Callback(hObject, eventdata, handles)
% hObject    handle to emul_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global NFB_ROOTDIR
jar_file = fullfile(NFB_ROOTDIR,'java','gui_copy','dist','gui_copy.jar');
% tauer::06.03.08    
% using ispc is faster and works on 64-bit too
if ispc
    winopen(jar_file);
else
    system_call = sprintf('java -jar %s &',jar_file);
    system(system_call);
end

%e.o.f.
