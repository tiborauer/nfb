% draw the figures for the feedback slider
% in1 ... positiv percent change for the maximum nfb-level (21)
% in2 ... negative percent change for the minimum nfb-level (1)
% in3 ... cell array of names of targ_roi(s) (optional)
% outputs ... figure handles

function varargout = gui_feedback_slider(varargin)
% GUI_FEEDBACK_SLIDER M-file for gui_feedback_slider.fig
%      GUI_FEEDBACK_SLIDER, by itself, creates a new GUI_FEEDBACK_SLIDER or raises the existing
%      singleton*.
%
%      H = GUI_FEEDBACK_SLIDER returns the handle to a new GUI_FEEDBACK_SLIDER or the handle to
%      the existing singleton*.
%
%      GUI_FEEDBACK_SLIDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FEEDBACK_SLIDER.M with the given input arguments.
%
%      GUI_FEEDBACK_SLIDER('Property','Value',...) creates a new GUI_FEEDBACK_SLIDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_feedback_slider_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_feedback_slider_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_feedback_slider

% Last Modified by GUIDE v2.5 30-Mar-2009 17:24:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_feedback_slider_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_feedback_slider_OutputFcn, ...
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


% --- Executes just before gui_feedback_slider is made visible.
function gui_feedback_slider_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_feedback_slider (see VARARGIN)

global MAX_POS MAX_NEG;

% Choose default command line output for gui_feedback_slider
handles.output = hObject;

fb = varargin{1};

if fb.max_pos > get(handles.slider1,'Max')
    set(handles.slider1,'Max', 2*varargin{1});
end
if fb.max_neg < get(handles.slider2,'Min')
    set(handles.slider2,'Min', 2*varargin{2});
end
handles.mvpc = varargin{3};

if handles.mvpc
    handles.max_pos = 1;
    handles.max_neg = 0;
    set(handles.slider1, 'Enable', 'off');
    set(handles.slider2, 'Enable', 'off');
 else
    handles.max_pos = fb.max_pos;
    handles.max_neg = fb.max_neg;
end
MAX_POS = handles.max_pos;
MAX_NEG = handles.max_neg;
handles.slider1max = get(handles.slider1,'Max');
handles.slider1min = get(handles.slider1,'Min');
set(handles.edit1,'String',num2str(handles.max_pos));
en = {'on' 'off'};
set(handles.slider1,'Enable',en{fb.shaping_yn+1});
set(handles.slider2,'Enable',en{fb.shaping_yn+1});
set(handles.slider1,'Value',handles.max_pos);
handles.slider2max = get(handles.slider2,'Max');
handles.slider2min = get(handles.slider2,'Min');
set(handles.edit2,'String',num2str(handles.max_neg));
set(handles.slider2,'Value',handles.max_neg);

global ROI;
for ir = 1:numel(ROI)
    set(handles.(['rbt' num2str(ir)]), 'String', varargin{2}{ir});
    set(handles.(['rbt' num2str(ir)]), 'Visible', 'on');
    set(handles.(['rbe' num2str(ir)]), 'Visible', 'on');
    set(handles.(['rbe' num2str(ir)]), 'Userdata', ir);
    set(handles.(['rbe' num2str(ir)]), 'String', num2str(ROI(ir)));
    set(handles.(['rbd' num2str(ir)]), 'Visible', 'on');
    ud(1) = -ir;
    ud(2) = handles.(['rbe' num2str(ir)]);
    set(handles.(['rbd' num2str(ir)]), 'Userdata', ud);    
    set(handles.(['rbd' num2str(ir)]), 'Callback', @change_ROI)
    set(handles.(['rbu' num2str(ir)]), 'Visible', 'on');
    ud(1) = ir;
    ud(2) = handles.(['rbe' num2str(ir)]);
    set(handles.(['rbu' num2str(ir)]), 'Userdata', ud);    
    set(handles.(['rbu' num2str(ir)]), 'Callback', @change_ROI)
    if handles.mvpc
        set(handles.(['rbe' num2str(ir)]), 'Enable', 'off');
        set(handles.(['rbd' num2str(ir)]), 'Enable', 'off');
        set(handles.(['rbu' num2str(ir)]), 'Enable', 'off');
    end
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_feedback_slider wait for user response (see UIRESUME)
% uiwait(handles.feedback_slider);


% --- Outputs from this function are returned to the command line.
function varargout = gui_feedback_slider_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
h = findobj('Name','Neurofeedback Status Window');
figure(h);
global MAX_POS;
handles.max_pos = get(hObject,'Value');
% round to 1 decimal place
handles.max_pos = round(handles.max_pos/0.1)*0.1;
set(handles.edit1,'String',num2str(handles.max_pos));
MAX_POS = handles.max_pos;
fprintf('Positive cut-off changed to %s\n',num2str(MAX_POS));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% set(hObject,'Value',[handles.val]);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
h = findobj('Name','Neurofeedback Status Window');
figure(h);
global MAX_POS;
handles.max_pos = str2double(get(hObject,'String'));
handles.max_pos = round(handles.max_pos/0.1)*0.1;
if handles.max_pos < handles.slider1min
    handles.max_pos = handles.slider1min;
end
if handles.max_pos > handles.slider1max
    handles.max_pos = handles.slider1max;
end
set(handles.edit1,'String',num2str(handles.max_pos));
set(handles.slider1,'Value',handles.max_pos);
MAX_POS = handles.max_pos;
fprintf('Positive cut-off changed to %s\n',num2str(MAX_POS));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);




% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
h = findobj('Name','Neurofeedback Status Window');
figure(h);
global MAX_NEG;
handles.max_neg = get(hObject,'Value');
handles.max_neg = round(handles.max_neg/0.1)*0.1;
set(handles.edit2,'String',num2str(handles.max_neg));
MAX_NEG = handles.max_neg;
fprintf('Negative cut-off changed to %s\n',num2str(MAX_NEG));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
h = findobj('Name','Neurofeedback Status Window');
figure(h);
global MAX_NEG;
handles.max_neg = str2double(get(hObject,'String'));
handles.max_neg = round(handles.max_neg/0.1)*0.1;
if handles.max_neg < handles.slider2min
    handles.max_neg = handles.slider2min;
end
if handles.max_neg > handles.slider2max
    handles.max_neg = handles.slider2max;
end
set(handles.edit2,'String',num2str(handles.max_neg));
set(handles.slider2,'Value',handles.max_neg);
MAX_NEG = handles.max_neg;
fprintf('Negitive cut-off changed to %s\n',num2str(MAX_neg));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function change_ROI(hObject, event)
global ROI ROI_CHNG;
ROI_CHNG = true;
ud = get(hObject,'Userdata');
ir = ud(1);
inc = (ir > 0)*2-1;
ir = ir * inc;
ROI(ir) = ROI(ir)+inc;
set(ud(2), 'String', num2str(ROI(ir)));

function rbe1_Callback(hObject, eventdata, handles)
% hObject    handle to rbe1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe1 as text
%        str2double(get(hObject,'String')) returns contents of rbe1 as a double


% --- Executes during object creation, after setting all properties.
function rbe1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe2_Callback(hObject, eventdata, handles)
% hObject    handle to rbe2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe2 as text
%        str2double(get(hObject,'String')) returns contents of rbe2 as a double


% --- Executes during object creation, after setting all properties.
function rbe2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe3_Callback(hObject, eventdata, handles)
% hObject    handle to rbe3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe3 as text
%        str2double(get(hObject,'String')) returns contents of rbe3 as a double


% --- Executes during object creation, after setting all properties.
function rbe3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe4_Callback(hObject, eventdata, handles)
% hObject    handle to rbe4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe4 as text
%        str2double(get(hObject,'String')) returns contents of rbe4 as a double


% --- Executes during object creation, after setting all properties.
function rbe4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe5_Callback(hObject, eventdata, handles)
% hObject    handle to rbe5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe5 as text
%        str2double(get(hObject,'String')) returns contents of rbe5 as a double


% --- Executes during object creation, after setting all properties.
function rbe5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe6_Callback(hObject, eventdata, handles)
% hObject    handle to rbe6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe6 as text
%        str2double(get(hObject,'String')) returns contents of rbe6 as a double


% --- Executes during object creation, after setting all properties.
function rbe6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe7_Callback(hObject, eventdata, handles)
% hObject    handle to rbe7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe7 as text
%        str2double(get(hObject,'String')) returns contents of rbe7 as a double


% --- Executes during object creation, after setting all properties.
function rbe7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe8_Callback(hObject, eventdata, handles)
% hObject    handle to rbe8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe8 as text
%        str2double(get(hObject,'String')) returns contents of rbe8 as a double


% --- Executes during object creation, after setting all properties.
function rbe8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbe9_Callback(hObject, eventdata, handles)
% hObject    handle to rbe9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbe9 as text
%        str2double(get(hObject,'String')) returns contents of rbe9 as a double


% --- Executes during object creation, after setting all properties.
function rbe9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbe9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in rbu1.
function rbu1_Callback(hObject, eventdata, handles)
% hObject    handle to rbu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd1.
function rbd1_Callback(hObject, eventdata, handles)
% hObject    handle to rbd1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu2.
function rbu2_Callback(hObject, eventdata, handles)
% hObject    handle to rbu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd2.
function rbd2_Callback(hObject, eventdata, handles)
% hObject    handle to rbd2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu3.
function rbu3_Callback(hObject, eventdata, handles)
% hObject    handle to rbu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd3.
function rbd3_Callback(hObject, eventdata, handles)
% hObject    handle to rbd3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu4.
function rbu4_Callback(hObject, eventdata, handles)
% hObject    handle to rbu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd4.
function rbd4_Callback(hObject, eventdata, handles)
% hObject    handle to rbd4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu5.
function rbu5_Callback(hObject, eventdata, handles)
% hObject    handle to rbu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd5.
function rbd5_Callback(hObject, eventdata, handles)
% hObject    handle to rbd5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu6.
function rbu6_Callback(hObject, eventdata, handles)
% hObject    handle to rbu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd6.
function rbd6_Callback(hObject, eventdata, handles)
% hObject    handle to rbd6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu7.
function rbu7_Callback(hObject, eventdata, handles)
% hObject    handle to rbu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd7.
function rbd7_Callback(hObject, eventdata, handles)
% hObject    handle to rbd7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu8.
function rbu8_Callback(hObject, eventdata, handles)
% hObject    handle to rbu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd8.
function rbd8_Callback(hObject, eventdata, handles)
% hObject    handle to rbd8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbu9.
function rbu9_Callback(hObject, eventdata, handles)
% hObject    handle to rbu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbd9.
function rbd9_Callback(hObject, eventdata, handles)
% hObject    handle to rbd9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


