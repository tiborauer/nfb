function varargout = gui_copy(varargin)
% GUI_COPY M-file for gui_copy.fig
%      GUI_COPY, by itself, creates a new GUI_COPY or raises the existing
%      singleton*.
%
%      H = GUI_COPY returns the handle to a new GUI_COPY or the handle to
%      the existing singleton*.
%
%      GUI_COPY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_COPY.M with the given input arguments.
%
%      GUI_COPY('Property','Value',...) creates a new GUI_COPY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_copy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_copy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_copy

% Last Modified by GUIDE v2.5 19-Sep-2007 10:45:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_copy_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_copy_OutputFcn, ...
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


% --- Executes just before gui_copy is made visible.
function gui_copy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_copy (see VARARGIN)

% Choose default command line output for gui_copy
handles.output = hObject;

% check if there is a gui_config.txt file in the gui directory and get
% default values
root_dir = fileparts(which('nfb.m'));
gui_config_file = fullfile(root_dir,'rtconfig.txt');
if exist(gui_config_file,'file')
    % same strategy as in nfb_main
    fid = fopen(gui_config_file);
    C = textscan(fid,'%s %s','commentStyle','%','Delimiter','\t');
    fclose(fid);
    guiconfig.var = C{1};
    guiconfig.val = C{2};

    % select the default watch directory as source directory for gui_copy
    % because it should contain sample data Analyze files
    handles.sourcedir = char(guiconfig.val(strcmp(guiconfig.var,'watch_dir')));
    % default watch directory is Matlab root
    handles.watchdir = matlabroot;
    % default number of volumes to be copied
    handles.volumes = str2double(char(guiconfig.val(strcmp(guiconfig.var,'volumes'))));
    % default TR
    handles.tr = str2double(char(guiconfig.val(strcmp(guiconfig.var,'TR'))));
else
    % file selection stuff
    handles.sourcedir = matlabroot;
    handles.watchdir = matlabroot;
    handles.volumes = 180;
    handles.tr = 2;
end

% set some further variables
handles.basename = 'Analyze';
handles.del = 0;
handles.running = 0;

% source and watch directory must not be equivalent
if strcmp(handles.sourcedir,handles.watchdir)
    warndlg('Source and watch directories must differ','Warning!!!');
end

set(handles.sourcedir_text,'String',handles.sourcedir);
set(handles.watchdir_text,'String',handles.watchdir);
set(handles.basename_text,'String',handles.basename);
set(handles.tr_text,'String',num2str(handles.tr,3));
set(handles.volume_text,'String',int2str(handles.volumes));
% tauer::06.03.08
% save value to be able to resore -> allfiles_radiobutton
set(handles.volume_text,'UserData',int2str(handles.volumes));
set(handles.status_text,'String','');
set(handles.warn_text,'String','');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_copy wait for user response (see UIRESUME)
% uiwait(handles.copy_fig);

% --- Outputs from this function are returned to the command line.
function varargout = gui_copy_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in sourcedir_button.
function sourcedir_button_Callback(hObject, eventdata, handles)
% hObject    handle to sourcedir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
d = uigetdir(handles.sourcedir,'Please select the source folder');
if d
    handles.sourcedir = d;
end
set(handles.sourcedir_text,'String',handles.sourcedir);
if strcmp(handles.sourcedir,handles.watchdir)
    warndlg('Source and watch directories must differ','Warning!!!');
end
guidata(hObject, handles);


% --- Executes on button press in watchdir_button.
function watchdir_button_Callback(hObject, eventdata, handles)
% hObject    handle to watchdir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
d = uigetdir(handles.watchdir,'Please select the watch folder');
if d
    handles.watchdir = d;
end
set(handles.watchdir_text,'String',handles.watchdir);
if strcmp(handles.sourcedir,handles.watchdir)
    warndlg('Source and watch directories must differ','Warning!!!');
end
guidata(hObject, handles);



function sourcedir_text_Callback(hObject, eventdata, handles)
% hObject    handle to sourcedir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
handles.sourcedir = get(hObject,'String');
if ~exist(handles.sourcedir,'dir')
    warndlg('Source directory does not exist. Please select a valid directory!'...
        ,'Warning!!!');
end
if strcmp(handles.sourcedir,handles.watchdir)
    warndlg('Source and watch directories must differ','Warning!!!');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sourcedir_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sourcedir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function watchdir_text_Callback(hObject, eventdata, handles)
% hObject    handle to watchdir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
handles.watchdir = get(hObject,'String');
if exist(handles.watchdir,'dir')
    warndlg('Watch directory does not exist. Please select a valid directory!'...
        ,'Warning!!!');
end
if strcmp(handles.sourcedir,handles.watchdir)
    warndlg('Source and watch directories must differ','Warning!!!');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function watchdir_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to watchdir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function basename_text_Callback(hObject, eventdata, handles)
% hObject    handle to basename_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
handles.basename = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function basename_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to basename_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tr_text_Callback(hObject, eventdata, handles)
% hObject    handle to tr_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
handles.tr = str2double(get(hObject,'String'));
guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function tr_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tr_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function volume_text_Callback(hObject, eventdata, handles)
% hObject    handle to volume_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.status_text,'String','');
set(handles.warn_text,'String','');
handles.volumes = str2double(get(hObject,'String'));
% tauer::06.03.08
% save value to be able to resore -> allfiles_radiobutton
set(handles.volume_text,'UserData',int2str(handles.volumes));
set(handles.allfiles_radiobutton,'Value',0);
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function volume_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volume_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in allfiles_radiobutton.
function allfiles_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to allfiles_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% try to estimate the number of Analyze header files in source directory
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
if get(hObject,'Value')
    if isunix
        headers = [handles.sourcedir '/' handles.basename '*.hdr'];
    elseif ispc
        headers = [handles.sourcedir '\' handles.basename '*.hdr'];
    end
    files = dir(headers);
    handles.volumes = size(files,1);    
    set(handles.volume_text,'String',int2str(handles.volumes));
else
% tauer::06.03.08
% resore data
    handles.volumes = str2double(get(handles.volume_text,'UserData'));
    set(handles.volume_text,'String',handles.volumes);    
end
guidata(hObject,handles);


% --- Executes on button press in delete_radiobutton.
function delete_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to delete_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','');
set(handles.warn_text,'String','');
handles.del = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in go_button.
function go_button_Callback(hObject, eventdata, handles)
% hObject    handle to go_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.running
    set(handles.status_text,'String','');
    set(handles.warn_text,'String','');
    handles.running = 1;
    guidata(hObject,handles);
    current_time = clock;
    handles.tr
    for n = 1:handles.volumes
        if n > 1
            while etime(clock,current_time) < handles.tr
% tauer::06.03.2008
% pause removed (unnecessary and occupy time)
%                pause(0.01);
            end
        end
        current_time = clock;
        copy_file(handles, sprintf('%s%05d.hdr',handles.basename,n));
        copy_file(handles, sprintf('%s%05d.img',handles.basename,n));
    end
    handles.running = 0;
    set(handles.status_text,'String','Done!');
    guidata(hObject,handles);
else
    warndlg('An instance of gui_copy is already running','Warning!!!');
end

function copy_file(handles, fn)
source = fullfile(handles.sourcedir,fn);
target = fullfile(handles.watchdir,fn);
if exist(target,'file')
    warn = sprintf('Files %s exists. Skipping ...\n',fn);
    set(handles.warn_text,'String',warn);
    if handles.del
        delete(source);
        set(handles.status_text,'String',['Deleting ' fn '...']);        
    end
else
    status = sprintf('\nNow processing file %s\n',fn);
    set(handles.status_text,'String',status);
    while ~exist(source, 'file')
% tauer::06.03.2008
% pause removed (unnecessary and occupy time)
%                pause(0.1);
    end
    fid_source = -1;
    while fid_source == -1
        fid_source = fopen(source,'r+');
% tauer::06.03.2008
% pause removed (unnecessary and occupy time)
%                pause(0.1);
    end
    fclose(fid_source);
    if handles.del
        if ~movefile(source,target)
            error('Failed to move file %s\n',source);
        end
    else
        if ~copyfile(source,target)
            error('Failed to copy file %s\n',source);
        end
    end
end    
%guidata(handles.copy_fig,handles);
% e.o.f.