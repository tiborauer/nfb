function varargout = gui_file_menu(varargin)
% File selection gui for the real-time fMRI setup gui
% called from gui_main_menu

% GUI_FILE_MENU M-file for gui_file_menu.fig
%      GUI_FILE_MENU, by itself, creates a new GUI_FILE_MENU or raises the existing
%      singleton*.
%
%      H = GUI_FILE_MENU returns the handle to a new GUI_FILE_MENU or the handle to
%      the existing singleton*.
%
%      GUI_FILE_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FILE_MENU.M with the given input arguments.
%
%      GUI_FILE_MENU('Property','Value',...) creates a new GUI_FILE_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_file_menu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_file_menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_file_menu

% Last Modified by GUIDE v2.5 29-Sep-2009 13:47:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_file_menu_OpeningFcn, ...
    'gui_OutputFcn',  @gui_file_menu_OutputFcn, ...
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



% --- Executes just before gui_file_menu is made visible.
function gui_file_menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_file_menu (see VARARGIN)

% default output, when no modification has been done
handles.output = false;
handles.data = varargin{3};

rtype = {'BrainVoyager', 'Nifti', 'Analyze'};
set(handles.pop_roidef, 'Value', find(ismember(rtype, handles.data.roi_def)));
set(handles.e_watch,'String',handles.data.watch_dir);
set(handles.e_trf,'String',handles.data.tr_dir);
set(handles.e_out,'String',handles.data.output_dir);
set(handles.pop_nroi,'Value',handles.data.no_roi+1);
for i = 1:handles.data.no_roi
    set(handles.(['targedit' int2str(i)]),'String',handles.data.(['targ_roi' num2str(i)]));
    set(handles.(['targedit' int2str(i)]),'Visible','on');
    set(handles.(['targbtn' int2str(i)]),'Visible','on');
    set(handles.(['ew' int2str(i)]),'Visible','on');
    set(handles.(['ew' int2str(i)]),'String',handles.data.(['w_roi' num2str(i)]));
end
set(handles.e_bg,'String',handles.data.bg_roi);
set(handles.e_pres,'String',handles.data.outfile);
set(handles.pop_flip,'Value', handles.data.flip_slice+1);

% bcp
handles.bcp = roi_bcp(handles.data);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_file_menu wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = gui_file_menu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check whather any modification has been done
if isfield(handles,'data') && isstruct(handles.data)
    varargout{1}.OK = true;
    varargout{1}.out = handles.data;
    delete(handles.figure1);
else
    varargout{1}.OK = false;
end


% selection of the watch directory
% --- Executes on button press in btn_watch.
function btn_watch_Callback(hObject, eventdata, handles)
% hObject    handle to btn_watch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
watch_dir = uigetdir(handles.data.watch_dir,'Please select the watch folder');
if watch_dir
    set(handles.e_watch,'String',watch_dir);
    handles.data.watch_dir = watch_dir;
    guidata(hObject, handles);
end


% selection of the watch directory
function e_watch_Callback(hObject, eventdata, handles)
% hObject    handle to e_watch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_watch as text
%        str2double(get(hObject,'String')) returns contents of e_watch as a double
watch_dir = get(hObject,'String');
handles.data.watch_dir = watch_dir;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_watch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_watch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% selection of the output directory
% --- Executes on button press in btn_out.
function btn_out_Callback(hObject, eventdata, handles)
% hObject    handle to btn_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out_dir = uigetdir(handles.data.output_dir,'Please select the output folder');
if out_dir
    set(handles.e_out,'String',out_dir);
    handles.data.output_dir = out_dir;
    guidata(hObject, handles);
end


% selection of the output directory
function e_out_Callback(hObject, eventdata, handles)
% hObject    handle to e_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_out as text
%        str2double(get(hObject,'String')) returns contents of e_out as a double
out_dir = get(hObject,'String');
handles.data.output_dir = out_dir;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_out_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% selection of the ROI type (BrainVoyager or Analyze)
% --- Executes on selection change in pop_roidef.
function pop_roidef_Callback(hObject, eventdata, handles)
% hObject    handle to pop_roidef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_roidef contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_roidef
contents = get(hObject,'String');
handles.data.roi_def = contents{get(hObject,'Value')};
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_roidef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_roidef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Background ROI selection
% --- Executes on button press in btn_bg.
function btn_bg_Callback(hObject, eventdata, handles)
% hObject    handle to btn_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.data.roi_def
    case 'Nifti'
        ext = '.nii.gz';
    case 'BrainVoyager'
        ext = '.roi';
    case 'Analyze'
        ext = '.hrd';
end
[bgf,bgd] = uigetfile(['*' ext],...
    ['Please select Background ' handles.data.roi_def ' ROI file'], handles.data.bg_roi);
if bgf
    bg_full = fullfile(bgd,bgf);
    set(handles.e_bg,'String',bg_full);
    % remove extension (will be added automatically)
    handles.data.bg_roi = strrep(bg_full,ext,'');
    guidata(hObject, handles);
end


% Background ROI selection
function e_bg_Callback(hObject, eventdata, handles)
% hObject    handle to e_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_bg as text
%        str2double(get(hObject,'String')) returns contents of e_bg as a double
bg_full = get(hObject,'String');
switch handles.data.roi_def
    case 'Nifti'
        ext = '.nii.gz';
    case 'BrainVoyager'
        ext = '.roi';
    case 'Analyze'
        ext = '.hrd';
end
% remove extension (will be added automatically)
handles.data.bg_roi = strrep(bg_full,ext,'');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_bg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Presentation file directory
% --- Executes on button press in btn_pres.
function btn_pres_Callback(hObject, eventdata, handles)
% hObject    handle to btn_pres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[p n e] = fileparts(handles.data.outfile);
p2 = uigetdir(p,'Please select folder for Presentation ROI file');
if p2
    handles.data.outfile = fullfile(p2,[n e]);
    guidata(hObject, handles);
end

% Presentation file name
function e_pres_Callback(hObject, eventdata, handles)
% hObject    handle to e_pres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_pres as text
%        str2double(get(hObject,'String')) returns contents of e_pres as a double
[p n e] = fileparts(handles.data.outfile);
n = get(hObject,'String');
handles.data.outfile = fullfile(p,n);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_pres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_pres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% close gui and return to gui_main_menu
% --- Executes on button press in btn_OK.
function btn_OK_Callback(hObject, eventdata, handles)
% hObject    handle to btn_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% Target ROI selection
% --- Executes on button press in targbtn1.
function targbtn1_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));

% Target ROI selection
function targedit1_Callback(hObject, eventdata, handles)
% hObject    handle to targedit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit1 as text
%        str2double(get(hObject,'String')) returns contents of targedit1 as a double
guidata(hObject, targedit(hObject, handles));


% --- Executes during object creation, after setting all properties.
function targedit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in targbtn2.
function targbtn2_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit2_Callback(hObject, eventdata, handles)
% hObject    handle to targedit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit2 as text
%        str2double(get(hObject,'String')) returns contents of targedit2 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in targbtn3.
function targbtn3_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit3_Callback(hObject, eventdata, handles)
% hObject    handle to targedit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit3 as text
%        str2double(get(hObject,'String')) returns contents of targedit3 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in targbtn4.
function targbtn4_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit4_Callback(hObject, eventdata, handles)
% hObject    handle to targedit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit4 as text
%        str2double(get(hObject,'String')) returns contents of targedit4 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in targbtn5.
function targbtn5_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit5_Callback(hObject, eventdata, handles)
% hObject    handle to targedit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit5 as text
%        str2double(get(hObject,'String')) returns contents of targedit5 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in targbtn6.
function targbtn6_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit6_Callback(hObject, eventdata, handles)
% hObject    handle to targedit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit6 as text
%        str2double(get(hObject,'String')) returns contents of targedit6 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in targbtn7.
function targbtn7_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit7_Callback(hObject, eventdata, handles)
% hObject    handle to targedit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit7 as text
%        str2double(get(hObject,'String')) returns contents of targedit7 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in targbtn8.
function targbtn8_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit8_Callback(hObject, eventdata, handles)
% hObject    handle to targedit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit8 as text
%        str2double(get(hObject,'String')) returns contents of targedit8 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in targbtn9.
function targbtn9_Callback(hObject, eventdata, handles)
% hObject    handle to targbtn9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, targbtn(hObject, handles));


function targedit9_Callback(hObject, eventdata, handles)
% hObject    handle to targedit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targedit9 as text
%        str2double(get(hObject,'String')) returns contents of targedit9 as a double
guidata(hObject, targedit(hObject, handles));

% --- Executes during object creation, after setting all properties.
function targedit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targedit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = targbtn(hObject, handles)
% hObject    handle to targbtn (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
name = get(hObject, 'tag');
ind = str2double(name(end));
switch handles.data.roi_def
    case 'Nifti'
        ext = '.nii.gz';
    case 'BrainVoyager'
        ext = '.roi';
    case 'Analyze'
        ext = '.hrd';
end
[targf,targp] = uigetfile(['*' ext],'Please select Target ROI file',...
    handles.data.(['targ_roi' num2str(ind)]));
if targf
    targ_full = fullfile(targp,targf);
    % remove extension (will be added automatically)
    handles.data.(['targ_roi' num2str(ind)]) = strrep(targ_full,ext,'');
    set(handles.(['targedit' num2str(ind)]),'String',targ_full);
end

function handles = targedit(hObject, handles)
% hObject    handle to targedit (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
name = get(hObject, 'tag');
ind = str2double(name(end));
targ_full = get(hObject,'String');
switch handles.data.roi_def
    case 'Nifti'
        ext = '.nii.gz';
    case 'BrainVoyager'
        ext = '.roi';
    case 'Analyze'
        ext = '.hrd';
end
% remove extension (will be added automatically)
handles.data.(['targ_roi' num2str(ind)]) = strrep(targ_full,ext,'');

function handles = targweight(hObject, handles)
% hObject    handle to targedit (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
name = get(hObject, 'tag');
ind = str2double(name(end));
handles.data.(['w_roi' num2str(ind)]) = str2double(get(hObject, 'String'));


% --- Executes on selection change in pop_nroi.
% here you can change the number of roi(s)
% if you decrease, the original targets will be saved; and when you increase again they will be loaded
% if you increase more the the original number, the new roi(s) will be the same as the last one.
function pop_nroi_Callback(hObject, eventdata, handles)
% hObject    handle to pop_nroi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_nroi contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_nroi
contents = get(hObject,'String');
nroi = str2double(contents{get(hObject,'Value')});
if nroi < handles.data.no_roi % decrease
    handles.bcp = roi_bcp(handles.data);
    handles.data = roi_erase(handles.data, nroi+1:handles.data.no_roi);
    for i = nroi+1:handles.data.no_roi
        set(handles.(['targedit' int2str(i)]),'Visible','off');
        set(handles.(['targbtn' int2str(i)]),'Visible','off');
        set(handles.(['ew' int2str(i)]),'Visible','off');
    end
elseif nroi > handles.data.no_roi
    for i = handles.data.no_roi+1:nroi
        if i <= handles.bcp.no_roi;
            n = i;
        else
            n = handles.bcp.no_roi;
        end
        handles.data.(['targ_roi' int2str(i)]) = handles.bcp.(['targ_roi' int2str(n)]);
        handles.data.(['w_roi' int2str(i)]) = handles.bcp.(['w_roi' int2str(n)]);
        set(handles.(['targedit' int2str(i)]),'String',handles.bcp.(['targ_roi' int2str(n)]));
        set(handles.(['targedit' int2str(i)]),'Visible','on');
        set(handles.(['targbtn' int2str(i)]),'Visible','on');
        set(handles.(['ew' int2str(i)]),'String',num2str(handles.bcp.(['w_roi' int2str(n)])));
        set(handles.(['ew' int2str(i)]),'Visible','on');
    end
end
handles.data.no_roi = nroi;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_nroi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_nroi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_flip.
function pop_flip_Callback(hObject, eventdata, handles)
% hObject    handle to pop_flip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_flip contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_flip
handles.data.flip_slice = logical(get(hObject, 'Value')-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_flip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_flip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ew1_Callback(hObject, eventdata, handles)
% hObject    handle to ew1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew1 as text
%        str2double(get(hObject,'String')) returns contents of ew1 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ew2_Callback(hObject, eventdata, handles)
% hObject    handle to ew2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew2 as text
%        str2double(get(hObject,'String')) returns contents of ew2 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ew3_Callback(hObject, eventdata, handles)
% hObject    handle to ew3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew3 as text
%        str2double(get(hObject,'String')) returns contents of ew3 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ew4_Callback(hObject, eventdata, handles)
% hObject    handle to ew4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew4 as text
%        str2double(get(hObject,'String')) returns contents of ew4 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ew5_Callback(hObject, eventdata, handles)
% hObject    handle to ew5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew5 as text
%        str2double(get(hObject,'String')) returns contents of ew5 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ew6_Callback(hObject, eventdata, handles)
% hObject    handle to ew6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew6 as text
%        str2double(get(hObject,'String')) returns contents of ew6 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ew7_Callback(hObject, eventdata, handles)
% hObject    handle to ew7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew7 as text
%        str2double(get(hObject,'String')) returns contents of ew7 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ew8_Callback(hObject, eventdata, handles)
% hObject    handle to ew8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew8 as text
%        str2double(get(hObject,'String')) returns contents of ew8 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ew9_Callback(hObject, eventdata, handles)
% hObject    handle to ew9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ew9 as text
%        str2double(get(hObject,'String')) returns contents of ew9 as a double
guidata(hObject, targweight(hObject, handles));

% --- Executes during object creation, after setting all properties.
function ew9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ew9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_trf.
function btn_trf_Callback(hObject, eventdata, handles)
% hObject    handle to btn_trf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tr_dir = uigetdir(handles.data.tr_dir,'Please select the transfer folder');
if tr_dir
    set(handles.e_trf,'String',tr_dir);
    handles.data.tr_dir = tr_dir;
    guidata(hObject, handles);
end


function e_trf_Callback(hObject, eventdata, handles)
% hObject    handle to e_trf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_trf as text
%        str2double(get(hObject,'String')) returns contents of e_trf as a double
handles.data.tr_dir = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_trf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_trf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function out = roi_bcp(in)
out.targ_roi0 = '';
out.w_roi0 = 0;
for i = 1:in.no_roi
    out.(['targ_roi' num2str(i)]) = in.(['targ_roi' num2str(i)]);
    out.(['w_roi' num2str(i)]) = in.(['w_roi' num2str(i)]);
end
out.no_roi = in.no_roi;

function out = roi_erase(in,n)
for i = 1:numel(n)
    out = rmfield(in, ['targ_roi' num2str(n(i))]);
    out = rmfield(out, ['w_roi' num2str(n(i))]);    
end