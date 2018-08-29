function varargout = gui_reference_menu(varargin)
% GUI_REFERENCE_MENU M-file for gui_reference_menu.fig
%      GUI_REFERENCE_MENU, by itself, creates a new GUI_REFERENCE_MENU or raises the existing
%      singleton*.
%
%      H = GUI_REFERENCE_MENU returns the handle to a new GUI_REFERENCE_MENU or the handle to
%      the existing singleton*.
%
%      GUI_REFERENCE_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_REFERENCE_MENU.M with the given input arguments.
%
%      GUI_REFERENCE_MENU('Property','Value',...) creates a new GUI_REFERENCE_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_reference_menu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_reference_menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_reference_menu

% Last Modified by GUIDE v2.5 08-Dec-2011 15:19:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_reference_menu_OpeningFcn, ...
    'gui_OutputFcn',  @gui_reference_menu_OutputFcn, ...
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


% --- Executes just before gui_reference_menu is made visible.
function gui_reference_menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_reference_menu (see VARARGIN)

% tauer:22.02.2008
% default output, when no modification has been done
handles.output = false;

handles.reference = varargin{3};
handles.data = varargin{4};
handles.timing = varargin{5};
handles = switch_mode(handles.reference.ref_type,handles);

set(handles.edit_reffile,'String',handles.reference.ref_file);
set(handles.edit_act,'String',int2str(handles.reference.ref_act));
set(handles.edit_deact,'String',int2str(handles.reference.ref_deact));
set(handles.edit_rest,'String',int2str(handles.reference.ref_control));
set(handles.edit_cycle,'String',int2str(handles.reference.ref_cycles));

set(handles.edit_base,'String',int2str(handles.reference.base_vols));
set(handles.edit_normstart,'String',int2str(handles.reference.norm_start));
set(handles.edit_normstop,'String',int2str(handles.reference.norm_stop));

set(handles.edit_fbstart,'String',int2str(handles.reference.fb_start));
set(handles.edit_fbstop,'String',int2str(handles.reference.fb_stop));

vis = {'off', 'on'};
set(handles.check_mvUse, 'Value', handles.reference.mv_MVPC);
set(handles.btn_TrainDir, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_TrainRef, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.edit_TrainDir, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.edit_TrainRef, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.text12, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.text13, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.text14, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.pop_mvModel, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.pop_mvData, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.pop_mvBg, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_TrainFile, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_Train, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_Check, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.edit_Train, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.panel_roi, 'Visible', vis{handles.reference.mv_MVPC+1});
for i = 1:handles.data.no_roi
    set(handles.(['chk' num2str(i)]), 'Visible', vis{handles.reference.mv_MVPC+1});
    [pth, fn] = fileparts(handles.data.(['targ_roi' num2str(i)]));
    set(handles.(['chk' num2str(i)]), 'String', fn);
    set(handles.(['chk' num2str(i)]), 'Value', 1);
end
set(handles.edit_TrainDir, 'String', handles.reference.mv_TrainData);
set(handles.edit_TrainRef, 'String', handles.reference.mv_TrainRef);
set(handles.pop_mvModel, 'Value', cell_index(get(handles.pop_mvModel,'String'),handles.reference.mv_Model));
set(handles.pop_mvData, 'Value', handles.reference.mv_Percent+1);
set(handles.pop_mvBg, 'Value', handles.reference.mv_bg+1);
set(handles.edit_Train, 'String', handles.reference.mv_Train);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_reference_menu wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_reference_menu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.reference.mv_MVPC && isempty(handles.reference.mv_Train))
    warndlg('No Trained Model specified.','Action needed!');
end
if isfield(handles,'reference') && isstruct(handles.reference)
    varargout{1}.OK = true;
    varargout{1}.reference = handles.reference;
    delete(handles.figure1);
else
    varargout{1}.OK = false;
end

% select type of reference function (block design or file)
% --- Executes on selection change in popupmenu_reftype.
function popupmenu_reftype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_reftype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_reftype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_reftype
contents = get(hObject,'String');
switch contents{get(hObject,'Value')}
    case 'File'
        handles = switch_mode('file',handles);
    case 'Block'
        handles = switch_mode('block',handles);
    case 'Operant conditioning'
        handles = switch_mode('opcond',handles);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_reftype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_reftype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% file selection dialog for the reference file
% --- Executes on button press in pushbutton_reffile.
function pushbutton_reffile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.reference.ref_type
    case 'file'
        [file,dir] = uigetfile('*.txt','Please select 1-column reference file',...
            handles.reference.ref_file);
        if file
            handles.reference.ref_file = fullfile(dir,file);
            set(handles.edit_reffile,'String',handles.reference.ref_file);
        end
    case 'block'
        warndlg('Reference type "File" not selected.','!! Zonk !!');
end
guidata(hObject, handles);


% file selection text for the reference file
function edit_reffile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_reffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_reffile as text
%        str2double(get(hObject,'String')) returns contents of edit_reffile as a double
handles.reference.ref_file = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_reffile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_reffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% number of active images
function edit_act_Callback(hObject, eventdata, handles)
% hObject    handle to edit_act (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_act as text
%        str2double(get(hObject,'String')) returns contents of edit_act as a double
handles.reference.ref_act = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_act_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_act (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% number of deactive images
function edit_deact_Callback(hObject, eventdata, handles)
% hObject    handle to edit_deact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_deact as text
%        str2double(get(hObject,'String')) returns contents of edit_deact as a double
handles.reference.ref_deact = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_deact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_deact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% number of control images
function edit_rest_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rest as text
%        str2double(get(hObject,'String')) returns contents of edit_rest as a double
handles.reference.ref_control = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_rest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% number of cycles
function edit_cycle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cycle as text
%        str2double(get(hObject,'String')) returns contents of edit_cycle as a double
handles.reference.ref_cycles = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_cycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% number of baseline images
function edit_base_Callback(hObject, eventdata, handles)
% hObject    handle to edit_base (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_base as text
%        str2double(get(hObject,'String')) returns contents of edit_base as a double
handles.reference.base_vols = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_base_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_base (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% when to start normalization
function edit_normstart_Callback(hObject, eventdata, handles)
% hObject    handle to edit_normstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_normstart as text
%        str2double(get(hObject,'String')) returns contents of edit_normstart as a double
handles.reference.norm_start = str2double(get(hObject,'String'));
check_norm(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_normstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_normstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% when to stop normalization
function edit_normstop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_normstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_normstop as text
%        str2double(get(hObject,'String')) returns contents of edit_normstop as a double
handles.reference.norm_stop = str2double(get(hObject,'String'));
check_norm(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_normstop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_normstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_preview.
function pushbutton_preview_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~check_norm(handles) || ~check_fb(handles), return; end

close(findobj('Tag','refdisplay'));
reference = nfb_reference(handles.reference);
reference(end+1:end+(handles.timing.volumes-numel(reference))) = 0;
vec = nfb_reference_proc(reference); eval(struct_extract(vec));

% modify Position: it was not visible on my display (1024x768)
% and put the Review window into the upper right corner
scr_unit = get(0, 'Units');
set(0, 'Units', 'characters');
scr_chr = get(0, 'ScreenSize');
set(0, 'Units', scr_unit);
ref_fig = figure('Name','Reference Function Display','NumberTitle','off',...
    'MenuBar','none','Units','characters','Position',[scr_chr(3)-113, scr_chr(4)-16.9, 112, 15],...%[103.8 63.15 112 15],...
    'Tag','refdisplay');

% check whether there is any baseline (e.g. set1)
bar(1:size(reference,1),active_vector,1,'r','EdgeColor','none',...
    'ShowBaseLine','off');
hold on
bar(1:size(reference,1),deactive_vector,1,'b','EdgeColor','none',...
    'ShowBaseLine','off');
%    hold on
% check whether there is any baseline (e.g. set1)
if reference(1) == 99 % isbase
    bar(1:size(reference,1),base_vector,1,'FaceColor',[0.5 0.5 0.5],...
        'EdgeColor','none','ShowBaseLine','off');
end

% this just plots a solid black line as baseline
plot(1:size(reference,1),zeros(1,size(reference,1)),'-k','LineWidth',2.5);

% volumes used for normalization are indicated separately
plot(1:size(reference,1),norm_plot,'-g','LineWidth',2.5);

% volumes used for feedback presentation are indicated separately
plot(1:size(reference,1),fb_plot,'-c','LineWidth',2.5);

axis([1 size(reference,1) 0 1]);
set(gca,'YTick',[],'TickLength',[0 0]);
xlabel('Time / Images');
saveas(ref_fig,'ref.fig');


% return to main menu
% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(findobj('Tag','refdisplay'));
uiresume(handles.figure1);


% reference function stuff is notoriously difficult to understand, so we
% provide some help
% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
root_dir = fileparts(which('gui_main_menu.m'));
ref_help = fullfile(root_dir,'help','reference_help.txt');
ref_help = importdata(ref_help);
msgbox(ref_help,'Nfb Toolbox Help');


% --- Executes on button press in check_mvUse.
function check_mvUse_Callback(hObject, eventdata, handles)
% hObject    handle to check_mvUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_mvUse
vis = {'off','on'};
handles.reference.mv_MVPC = get(hObject,'Value');
set(handles.check_mvUse, 'Value', handles.reference.mv_MVPC);
set(handles.btn_TrainDir, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_TrainRef, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.edit_TrainDir, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.edit_TrainRef, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.text12, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.text13, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.text14, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.pop_mvModel, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.pop_mvData, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.pop_mvBg, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_TrainFile, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_Train, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.btn_Check, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.edit_Train, 'Visible', vis{handles.reference.mv_MVPC+1});
set(handles.panel_roi, 'Visible', vis{handles.reference.mv_MVPC+1});
for i = 1:handles.data.no_roi
    set(handles.(['chk' num2str(i)]), 'Visible', vis{handles.reference.mv_MVPC+1});
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in pop_mvModel.
function pop_mvModel_Callback(hObject, eventdata, handles)
% hObject    handle to pop_mvModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_mvModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_mvModel
models = get(hObject,'String');
handles.reference.mv_Model = models{get(hObject,'Value')};

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_mvModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_mvModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_mvData.
function pop_mvData_Callback(hObject, eventdata, handles)
% hObject    handle to pop_mvData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_mvData contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_mvData
handles.reference.mv_Percent = get(hObject,'Value')-1;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_mvData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_mvData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_mvBg.
function pop_mvBg_Callback(hObject, eventdata, handles)
% hObject    handle to pop_mvBg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_mvBg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_mvBg
handles.reference.mv_bg = get(hObject,'Value')-1;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_mvBg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_mvBg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_TrainDir.
function btn_TrainDir_Callback(hObject, eventdata, handles)
% hObject    handle to btn_TrainDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outdir = uigetdir(handles.reference.mv_TrainData,'Select directory containing Train Data');
if (numel(outdir) > 1), handles.reference.mv_TrainData = outdir; end
set(handles.edit_TrainDir,'String',handles.reference.mv_TrainData);
guidata(hObject, handles);


function edit_TrainDir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TrainDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TrainDir as text
%        str2double(get(hObject,'String')) returns contents of edit_TrainDir as a double
handles.reference.mv_TrainData = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_TrainDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TrainDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_TrainRef_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TrainRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TrainRef as text
%        str2double(get(hObject,'String')) returns contents of edit_TrainRef as a double
handles.reference.mv_TrainRef = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_TrainRef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TrainRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_TrainRef.
function btn_TrainRef_Callback(hObject, eventdata, handles)
% hObject    handle to btn_TrainRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outdir = uigetdir(handles.reference.mv_TrainRef,'Select directory containing Train Reference');
if (numel(outdir) > 1), handles.reference.mv_TrainRef = outdir; end
set(handles.edit_TrainRef,'String',handles.reference.mv_TrainRef);
guidata(hObject, handles);


% --- Executes on button press in btn_TrainFile.
function btn_TrainFile_Callback(hObject, eventdata, handles)
% hObject    handle to btn_TrainFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)itioning
[file,dir] = uigetfile(...
    '*.mat','Please select MAT-file containing Trained Model',...
    handles.reference.mv_Train);
if file
    load(fullfile(dir,file));
    if ~strcmp(handles.reference.mv_TrainData, mvpc.cfg.Path2Train) ||...
            ~strcmp(handles.reference.mv_TrainRef, mvpc.cfg.RefDir_Train)
        warndlg('Not the same data!');
    else
        handles.reference.mv_Model = mvpc.cfg.Method;
        handles.reference.mv_Perc = mvpc.cfg.Perc;
        handles.reference.mv_bg = mvpc.cfg.Bg;
        handles.reference.mv_Train = fullfile(dir,file);
        
        for i = 1:numel(mvpc.cfg.ROI)
            [pth, fn] = fileparts(mvpc.cfg.Path2Roi{i});
            set(handles.(['chk' num2str(i)]), 'Visible', 'on');
            set(handles.(['chk' num2str(i)]), 'String', fn);
            set(handles.(['chk' num2str(i)]), 'Value', mvpc.cfg.ROI(i));
        end
        for i = numel(mvpc.cfg.ROI)+1:9
            set(handles.(['chk' num2str(i)]), 'Visible', 'off');
        end
        set(handles.pop_mvModel, 'Value', cell_index(get(handles.pop_mvModel,'String'),handles.reference.mv_Model));
        set(handles.pop_mvData, 'Value', handles.reference.mv_Percent+1);
        set(handles.pop_mvBg, 'Value', handles.reference.mv_bg+1);
        set(handles.edit_Train, 'String', handles.reference.mv_Train);
        
        guidata(hObject, handles);
    end
end


function edit_Train_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Train as text
%        str2double(get(hObject,'String')) returns contents of edit_Train as a double
handles.reference.mv_Train = get(handles.edit_Train,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_Train_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_Train.
function btn_Train_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cfg.Path2Train = handles.reference.mv_TrainData;
for i = 1:handles.data.no_roi
    cfg.Path2Roi{i} = handles.data.(['targ_roi' num2str(i)]);
end
cfg.Path2Roi{end+1} = handles.data.bg_roi;
for i = 1:handles.data.nroi
    cfg.ROI(i) = get(handles.(['chk' num2str(i)]), 'Value');
end
cfg.RefDir_Train = handles.reference.mv_TrainRef;
cfg.ShiftRef = 3;
cfg.Perc = handles.reference.mv_Percent;
cfg.Bg = handles.reference.mv_bg;
cfg.Method = handles.reference.mv_Model;
mvpc.cfg = cfg;
mvpc.model = mvpc_train(cfg);
[file,path] = uiputfile('*.mat','Save Trained Model',fullfile(fileparts(handles.data.targ_roi1), 'MVPC.mat'));
if (ischar(file) && ischar(path))
    mv_Train = fullfile(path, file);
    save(mv_Train, 'mvpc');
    handles.reference.mv_Train = mv_Train;
    set(handles.edit_Train, 'String', handles.reference.mv_Train);
end
mvpc_check(handles.reference.mv_Train);
guidata(hObject, handles);


% --- Executes on button press in chk1.
function chk1_Callback(hObject, eventdata, handles)
% hObject    handle to chk1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk1


% --- Executes on button press in chk2.
function chk2_Callback(hObject, eventdata, handles)
% hObject    handle to chk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk2


% --- Executes on button press in chk3.
function chk3_Callback(hObject, eventdata, handles)
% hObject    handle to chk3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk3


% --- Executes on button press in chk4.
function chk4_Callback(hObject, eventdata, handles)
% hObject    handle to chk4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk4


% --- Executes on button press in chk5.
function chk5_Callback(hObject, eventdata, handles)
% hObject    handle to chk5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk5


% --- Executes on button press in chk6.
function chk6_Callback(hObject, eventdata, handles)
% hObject    handle to chk6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk6


% --- Executes on button press in chk7.
function chk7_Callback(hObject, eventdata, handles)
% hObject    handle to chk7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk7


% --- Executes on button press in chk8.
function chk8_Callback(hObject, eventdata, handles)
% hObject    handle to chk8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk8


% --- Executes on button press in chk9.
function chk9_Callback(hObject, eventdata, handles)
% hObject    handle to chk9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk9


% --- Executes on button press in btn_Check.
function btn_Check_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mvpc_check(handles.reference.mv_Train);


function edit_fbstart_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fbstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fbstart as text
%        str2double(get(hObject,'String')) returns contents of edit_fbstart as a double
handles.reference.fb_start = str2num(get(hObject,'String'));
check_fb(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_fbstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fbstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_fbstop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fbstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fbstop as text
%        str2double(get(hObject,'String')) returns contents of edit_fbstop as a double
handles.reference.fb_stop = str2num(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_fbstop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fbstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UTILS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ok = check_norm(handles)
ok = true;
norm_length = (handles.reference.ref_control - handles.reference.norm_start - (-1*handles.reference.norm_stop));
if norm_length < 2
    ok = false;
    title_string = sprintf(...
        'Paradigm invalid. Normalization requested based on %s volumes but must be at least 2 volumes. Please revise!\n',...
        int2str(norm_length));
    warndlg(title_string,'Paradigm Inconsistency');
end

function ok = check_fb(handles)
ok = true;
if numel(handles.reference.fb_start) ~= numel(handles.reference.fb_stop)
    ok = false;
    title_string = sprintf('The numbers of feedback start and stop points do not match. Please revise!\n');
    warndlg(title_string,'Paradigm Inconsistency');
end
fb_length = handles.reference.ref_act + handles.reference.ref_control -...
    handles.reference.fb_start - (-1*handles.reference.fb_stop);
if fb_length < 1
    ok = false;
    title_string = sprintf('There is no feedback presented at all. Please revise!\n');
    warndlg(title_string,'Paradigm Inconsistency');
end


function handles = switch_mode(mode,handles)
switch mode
    case 'file'
        handles.reference.ref_type = 'file';
        set(handles.popupmenu_reftype,'Value',1);        
        set(handles.pushbutton_reffile,'Visible','on');
        set(handles.edit_reffile,'Visible','on');
        set(handles.panel_paradigm,'Visible','off');
        set(handles.panel_norm,'Visible','off');
    case 'block'
        handles.reference.ref_type = 'block';
        set(handles.popupmenu_reftype,'Value',2);
        set(handles.pushbutton_reffile,'Visible','off');
        set(handles.edit_reffile,'Visible','off');
        set(handles.panel_paradigm,'Visible','on');
        set(handles.edit_deact,'Enable','on');
        set(handles.edit_rest,'Enable','on');
        set(handles.panel_norm,'Visible','on');
        set(handles.edit_normstart,'Enable','on');
        set(handles.edit_normstop,'Enable','on');
    case 'opcond'
        handles.reference.ref_type = 'opcond';
        set(handles.popupmenu_reftype,'Value',3);
        set(handles.pushbutton_reffile,'Visible','off');
        set(handles.edit_reffile,'Visible','off');
        set(handles.panel_paradigm,'Visible','on');        
        set(handles.edit_deact,'Enable','off');
        set(handles.edit_rest,'Enable','off');
        set(handles.panel_norm,'Visible','on');
        set(handles.edit_normstart,'Enable','off');
        set(handles.edit_normstop,'Enable','off');
        handles = opcond_set(handles);
end

function handles = opcond_set(handles)
DELAY=10; % sec
if handles.reference.ref_act*handles.timing.TR > DELAY
    warndlg(sprintf('Operant conditioning cannot be\nperformed for longer than %d seconds.\n\nActivation time is set to max. %d seconds',DELAY,DELAY),'Note!');       
    handles.reference.ref_act = floor(DELAY/handles.timing.TR); 
end
if handles.reference.ref_deact > 0, handles.reference.ref_deact = handles.reference.ref_act; end
dscans=ceil(DELAY/handles.timing.TR);
handles.reference.ref_control = dscans + ... % end of feedback
    handles.reference.ref_act + ... % end of control task
    dscans; % end of feedback for control task
set(handles.edit_act,'String',int2str(handles.reference.ref_act));
set(handles.edit_deact,'String',int2str(handles.reference.ref_deact));
set(handles.edit_rest,'String',int2str(handles.reference.ref_control));

handles.reference.norm_start = handles.reference.ref_control-dscans;
handles.reference.norm_stop = 0;
set(handles.edit_normstart,'String',int2str(handles.reference.norm_start));
set(handles.edit_normstop,'String',int2str(handles.reference.norm_stop));

handles.reference.fb_start = [dscans handles.reference.ref_act+handles.reference.ref_control-handles.reference.ref_act];
handles.reference.fb_stop = [-(dscans + handles.reference.ref_act) 0];
set(handles.edit_fbstart,'String',int2str(handles.reference.fb_start));
set(handles.edit_fbstop,'String',int2str(handles.reference.fb_stop));
