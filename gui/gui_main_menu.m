function varargout = gui_main_menu(varargin)
% GUI_MAIN_MENU M-file for gui_main_menu.fig
%      GUI_MAIN_MENU, by itself, creates a new GUI_MAIN_MENU or raises the existing
%      singleton*.
%
%      H = GUI_MAIN_MENU returns the handle to a new GUI_MAIN_MENU or the handle to
%      the existing singleton*.
%
%      GUI_MAIN_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MAIN_MENU.M with the given input arguments.
%
%      GUI_MAIN_MENU('Property','Value',...) creates a new GUI_MAIN_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_main_menu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_main_menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_main_menu

% Last Modified by GUIDE v2.5 29-Sep-2009 09:49:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_main_menu_OpeningFcn, ...
    'gui_OutputFcn',  @gui_main_menu_OutputFcn, ...
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


% --- Executes just before gui_main_menu is made visible.
function gui_main_menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_main_menu (see VARARGIN)

% gives the opportunity to go to a dir in the begining (see. nfb.m)
rtf = '';
PIn = find(strcmp(varargin, 'file'));
if ~isempty(PIn)
    rtf = varargin{PIn+1};
    cd(fileparts(rtf));
end

% Choose default command line output for gui_main_menu
handles.output = false;

% read in a configuration file with default settings (if it exists in the
% same directory as gui_main_menu.m)
root_dir = nfb_dir;

def_rtf = 'rtconfig_defaults.txt';
handles.path_req{1} = root_dir;
handles.path_req{2} = fullfile(root_dir,'gui');
handles.path_req = horzcat(handles.path_req, genpath_cell(fullfile(root_dir,'include','mvpc')));
handles.mod = add_path(handles.path_req);

handles.ini = IniFile(rtf);
if ~handles.ini.isValid, handles.ini = IniFile(fullfile(root_dir, def_rtf)); end
handles.ini.Sanity(fullfile(root_dir, def_rtf));

% other options
set(handles.pop_plot,'Value',cell_index(upper(get(handles.pop_plot,'String')),upper(handles.ini.misc.plot_type)));

set(handles.check_run,'Value', ~handles.ini.misc.run);
set(handles.check_analyze,'Value', ~handles.ini.misc.eval);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_main_menu wait for user response (see UIRESUME)
% wait for gui_close to have the path until the prog. is on
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_main_menu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% remove path
rm_path(handles.mod, handles.path_req);
% Get default command line output from handles structure
varargout{1} = true;
delete(handles.figure1);
% close Neurofeedback Status Windows if there is any
h = findobj('Name', 'Neurofeedback Status Window');
if ~isempty(h)
    close(h);
end


% Opens the file selection dialog and gets pertinent variables for file
% and directory selection
% --- Executes on button press in btn_file.
function btn_file_Callback(hObject, eventdata, handles)
% hObject    handle to btn_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = gui_file_menu('NumberTitle','off',handles.ini.data);
if out.OK
    f = unique(vertcat(fieldnames(out.out), fieldnames(handles.ini.data)));
    nr = min([handles.ini.data.no_roi out.out.no_roi]); na = 0;
    difr = out.out.no_roi-handles.ini.data.no_roi;
    for i = 1:numel(f)
        if (isempty(findstr(f{i},'targ_roi')) && isempty(findstr(f{i},'w_roi'))) ||...
                (str2double(f{i}(end)) <= nr)
            handles.ini.data.(f{i}) = out.out.(f{i});
        else
            if difr < 0 % remove roi
                handles.ini = handles.ini.RemoveVariable('data',f{i});
            else % add roi
                handles.ini = handles.ini.AddVariable('data',6+nr+na,f{i},'s',out.out.(f{i}));
                na = na + 1;
            end
        end
    end
end
guidata(hObject, handles);


% Opens the timing dialog
% --- Executes on button press in btn_time.
function btn_time_Callback(hObject, eventdata, handles)
% hObject    handle to btn_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = gui_timing_menu('NumberTitle','off',handles.ini.timing);
if out.OK
    handles.ini.timing = out.out;
end

if total_vols(handles.ini.reference) ~= handles.ini.timing.volumes
    warn_string = sprintf(...
        'Mismatch! You specified %s volumes in timing menu and %s volumes in reference menu. Please revise!'...
        ,int2str(handles.ini.timing.volumes),int2str(total_vols(handles.ini.reference)));
    w = warndlg(warn_string);
end

guidata(hObject, handles);


% Dialog for reference fucntion creation
% --- Executes on button press in btn_ref.
function btn_ref_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = gui_reference_menu('NumberTitle','off',handles.ini.reference, handles.ini.data, handles.ini.timing);
if out.OK
    handles.ini.reference = out.reference;
end

if total_vols(handles.ini.reference) > handles.ini.timing.volumes
    warn_string = sprintf(...
        'Mismatch! You specified %s volumes in timing menu and %s volumes in reference menu.\nNumber of volumes in Timing has been modified.'...
        ,int2str(handles.ini.timing.volumes),int2str(total_vols(handles.ini.reference)));
    warndlg(warn_string);
    handles.ini.timing.volumes = total_vols(handles.ini.reference);
end

guidata(hObject, handles);


% Preprocessing options
% --- Executes on button press in btn_preproc.
function btn_preproc_Callback(hObject, eventdata, handles)
% hObject    handle to btn_preproc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = gui_preproc_menu('NumberTitle','off',handles.ini.preprocess);
if out.OK
    handles.ini.preprocess = out.out;
end
guidata(hObject, handles);

% Feedback specifications
% --- Executes on button press in btn_fb.
function btn_fb_Callback(hObject, eventdata, handles)
% hObject    handle to btn_fb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = gui_feedback_menu('NumberTitle','off',handles.ini.feedback);
if out.OK
    handles.ini.feedback = out.out;
end
guidata(hObject, handles);

% Plotting options
% --- Executes on selection change in pop_plot.
function pop_plot_Callback(hObject, eventdata, handles)
% hObject    handle to pop_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_plot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_plot
plot = get(hObject,'UserData');
handles.ini.misc.plot_type = plot{get(hObject,'Value')};

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% Check to switch off evaluation (just check config file)
% --- Executes on button press in check_run.
function check_run_Callback(hObject, eventdata, handles)
% hObject    handle to check_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_run
handles.ini.misc.run = get(hObject,'Value') ~= get(hObject,'Max');
guidata(hObject, handles);

% tick switches post-neurofeedback analysis off
% --- Executes on button press in check_analyze.
function check_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to check_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_analyze
handles.ini.misc.eval = get(hObject,'Value') ~= get(hObject,'Max');
guidata(hObject, handles);

% Save button --> selects a file name and writes guiconfig data to this file
% --- Executes on button press in btn_save.
function btn_save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[config_file, config_path] = uiputfile('*.txt','Select configuration file for saving');
if any(config_file)
    handles.ini.Close(fullfile(config_path, config_file)); 
    guidata(hObject, handles);
end

% Click to run the analysis
% --- Executes on button press in btn_go.
function btn_go_Callback(hObject, eventdata, handles)
% hObject    handle to btn_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nfb_main(handles.ini);
guidata(hObject, handles);

% load config file
% --- Executes on button press in btn_load.
function btn_load_Callback(hObject, eventdata, handles)
% hObject    handle to btn_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[config_file, config_path] = uigetfile('*.txt','Select configuration file for loading');
if any(config_file)
    ini = IniFile(fullfile(config_path, config_file));
    if ini.isValid
        handles.ini = ini;
        handles.ini.Sanity(fullfile(nfb_dir, 'rtconfig_defaults.txt'));        
        
        % other options
        set(handles.pop_plot,'Value',cell_index(upper(get(handles.pop_plot,'String')),upper(handles.ini.misc.plot_type)));
        
        set(handles.check_run,'Value', ~handles.ini.misc.run);
        set(handles.check_analyze,'Value', ~handles.ini.misc.eval);
        
        % Update handles structure
        guidata(hObject, handles);
    end
end

% functions to handle path settings
function mod = add_path(req)
p = path;
mod = false(1,numel(req));
if isunix
    sep = ':';
else
    sep = ';';
end
for i = 1:numel(req)
    if isempty(findstr([req{i} sep],p))
        addpath(req{i});
        mod(i) = true;
    end
end
return

function rm_path(mod, req)
for i = 1:numel(req)
    if mod(i)
        rmpath(req{i});
    end
end
return

function nvol = total_vols(str)
if ~str.ref_deact
    nvol = str.base_vols + str.ref_control + ((str.ref_act + str.ref_control)*str.ref_cycles);
else
    nvol = str.base_vols + str.ref_control + ((str.ref_act + str.ref_deact + 2*str.ref_control)*str.ref_cycles);
end
% e.o.f.
