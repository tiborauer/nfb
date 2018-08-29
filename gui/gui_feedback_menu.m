function varargout = gui_feedback_menu(varargin)
% GUI_FEEDBACK_MENU M-file for gui_feedback_menu.fig
%      GUI_FEEDBACK_MENU, by itself, creates a new GUI_FEEDBACK_MENU or raises the existing
%      singleton*.
%
%      H = GUI_FEEDBACK_MENU returns the handle to a new GUI_FEEDBACK_MENU or the handle to
%      the existing singleton*.
%
%      GUI_FEEDBACK_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FEEDBACK_MENU.M with the given input arguments.
%
%      GUI_FEEDBACK_MENU('Property','Value',...) creates a new GUI_FEEDBACK_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_feedback_menu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_feedback_menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_feedback_menu

% Last Modified by GUIDE v2.5 22-Dec-2011 12:53:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_feedback_menu_OpeningFcn, ...
    'gui_OutputFcn',  @gui_feedback_menu_OutputFcn, ...
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


% --- Executes just before gui_feedback_menu is made visible.
function gui_feedback_menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_feedback_menu (see VARARGIN)

% default output, when no modification has been done
handles.output = false;

handles.fb = varargin{3};

set(handles.pop_method, 'Value', handles.fb.method);
set(handles.chk_shaping, 'Value',handles.fb.shaping_yn);
handles = switch_mode(handles);

% to handle input values bigger than fbmax_slidermax or fbmin_slidermax
if handles.fb.max_pos > get(handles.fbmax_slider,'Max')
    set(handles.fbmax_slider,'Max', 2*handles.fb.max_pos);
end
if handles.fb.max_neg < get(handles.fbmin_slider,'Min')
    set(handles.fbmin_slider,'Min', 2*handles.fb.max_neg);
end
set(handles.fbmax_edit,'String',num2str(handles.fb.max_pos));
set(handles.fbmin_edit,'String',num2str(handles.fb.max_neg));
set(handles.fbmax_slider,'Value',handles.fb.max_pos);
set(handles.fbmin_slider,'Value',handles.fb.max_neg);
handles.fbmax_slidermax = get(handles.fbmax_slider,'Max');
handles.fbmax_slidermin = get(handles.fbmax_slider,'Min');
handles.fbmin_slidermax = get(handles.fbmin_slider,'Max');
handles.fbmin_slidermin = get(handles.fbmin_slider,'Min');

% controls of breakpoints
brset = [handles.fb.break_low, handles.fb.break_high,...
    handles.fb.sl_middle, handles.fb.sl_extremity];
set(handles.brslider1, 'Max', handles.fb.break_high-0.01);
set(handles.brslider2, 'Min', handles.fb.break_low+0.01);
set(handles.brslider3, 'Max', 1-2*handles.fb.sl_extremity);
set(handles.brslider4, 'Max', (1-handles.fb.sl_middle)/2);
for i = 1:4
    set(handles.(['brslider' int2str(i)]),'Value', brset(i));
    set(handles.(['brslider' int2str(i)]),'UserData', get(handles.(['brslider' int2str(i)]), 'SliderStep'));
    set_slider(handles.(['brslider' int2str(i)]));
    set(handles.(['bredit' int2str(i)]),'String', num2str(brset(i)));
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_feedback_menu wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_feedback_menu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'fb') && isstruct(handles.fb)
    varargout{1}.OK = true;
    varargout{1}.out = handles.fb;
    delete(handles.figure1);
end


% Positive saturation point
function fbmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to fbmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fbmax_edit as text
%        str2double(get(hObject,'String')) returns contents of fbmax_edit as a double
handles.fb.max_pos = str2double(get(hObject,'String'));
handles.fb.max_pos = slider_chk('Positive feedback', round(handles.fb.max_pos/0.1)*0.1, handles.fbmax_slider);
set(handles.fbmax_edit,'String',num2str(handles.fb.max_pos));
set(handles.fbmax_slider,'Value',handles.fb.max_pos);

% using function to (re)draw slope
slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function fbmax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fbmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Negative saturation point
function fbmin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to fbmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fbmin_edit as text
%        str2double(get(hObject,'String')) returns contents of fbmin_edit as a double
handles.fb.max_neg = str2double(get(hObject,'String'));
handles.fb.max_neg = slider_chk('Negative feedback', round(handles.fb.max_neg/0.1)*0.1, handles.fbmin_slider);
set(handles.fbmin_edit,'String',num2str(handles.fb.max_neg));
set(handles.fbmin_slider,'Value',handles.fb.max_neg);

% using function to (re)draw slope
slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function fbmin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fbmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function fbmax_slider_Callback(hObject, eventdata, handles)
% hObject    handle to fbmax_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fb.max_pos = get(hObject,'Value');
handles.fb.max_pos = round(handles.fb.max_pos/0.1)*0.1;
set(handles.fbmax_edit,'String',num2str(handles.fb.max_pos));

% using function to (re)draw slope
slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function fbmax_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fbmax_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function fbmin_slider_Callback(hObject, eventdata, handles)
% hObject    handle to fbmin_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fb.max_neg = get(hObject,'Value');
handles.fb.max_neg = round(handles.fb.max_neg/0.1)*0.1;
set(handles.fbmin_edit,'String',num2str(handles.fb.max_neg));

% using function to (re)draw slope
slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function fbmin_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fbmin_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% close gui and return to gui_main_menu
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);



% --- Executes on slider movement.
function brslider1_Callback(hObject, eventdata, handles)
% hObject    handle to brslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fb.break_low = get(hObject,'Value');
handles.fb.break_low = round(handles.fb.break_low/0.01)*0.01;
set(handles.bredit1,'String',num2str(handles.fb.break_low));
set(handles.brslider2, 'Min', round((handles.fb.break_low+0.01)/0.01)*0.01);
set_slider(handles.brslider2);

% using function to (re)draw slope
slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function brslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function bredit1_Callback(hObject, eventdata, handles)
% hObject    handle to bredit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bredit1 as text
%        str2double(get(hObject,'String')) returns contents of bredit1 as a double
handles.fb.break_low = str2double(get(hObject,'String'));
handles.fb.break_low = slider_chk('Threshold (in % signal) to reach the steeper rise', round(handles.fb.break_low/0.01)*0.01, handles.brslider1);
set(handles.bredit1,'String',num2str(handles.fb.break_low));
set(handles.brslider1,'Value',handles.fb.break_low);
set(handles.brslider2, 'Min', round((handles.fb.break_low+0.01)/0.01)*0.01);
set_slider(handles.brslider2);

slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bredit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bredit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function brslider2_Callback(hObject, eventdata, handles)
% hObject    handle to brslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fb.break_high = get(hObject,'Value');
handles.fb.break_high = round(handles.fb.break_high/0.01)*0.01;
set(handles.bredit2,'String',num2str(handles.fb.break_high));
set(handles.brslider1, 'Max', round((handles.fb.break_high-0.01)/0.01)*0.01);
set_slider(handles.brslider1);

% using function to (re)draw slope
slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function brslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function bredit2_Callback(hObject, eventdata, handles)
% hObject    handle to bredit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bredit2 as text
%        str2double(get(hObject,'String')) returns contents of bredit2 as a double
handles.fb.break_high = str2double(get(hObject,'String'));
handles.fb.break_high = slider_chk('Threshold (in % signal) to reach the more shallow rise in the extreme part', round(handles.fb.break_high/0.01)*0.01, handles.brslider2);
set(handles.bredit2,'String',num2str(handles.fb.break_high));
set(handles.brslider2,'Value',handles.fb.break_high);
set(handles.brslider1, 'Max', round((handles.fb.break_high-0.01)/0.01)*0.01);
set_slider(handles.brslider1);

slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bredit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bredit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function brslider3_Callback(hObject, eventdata, handles)
% hObject    handle to brslider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fb.sl_middle = get(hObject,'Value');
% 0.001 was needed, because the calculation (without infinite decimals)
% produce sometimes number just below the limit
handles.fb.sl_middle = floor(handles.fb.sl_middle/0.05+0.001)*0.05;
set(hObject, 'Value', handles.fb.sl_middle);
set(handles.bredit3,'String',num2str(handles.fb.sl_middle));
set(handles.brslider4, 'Max', (1-handles.fb.sl_middle)/2+0.001);
set_slider(handles.brslider4);

slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function brslider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brslider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function bredit3_Callback(hObject, eventdata, handles)
% hObject    handle to bredit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bredit3 as text
%        str2double(get(hObject,'String')) returns contents of bredit3 as a double
handles.fb.sl_middle = str2double(get(hObject,'String'));
handles.fb.sl_middle = slider_chk('Ratio of the middle part to the whole slope', floor(handles.fb.sl_middle/0.05+0.001)*0.05, handles.brslider3);
set(handles.bredit3,'String',num2str(handles.fb.sl_middle));
set(handles.brslider3,'Value',handles.fb.sl_middle);

slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bredit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bredit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on slider movement.
function brslider4_Callback(hObject, eventdata, handles)
% hObject    handle to brslider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fb.sl_extremity = get(hObject,'Value');
handles.fb.sl_extremity = floor(handles.fb.sl_extremity/0.05+0.001)*0.05;
set(hObject, 'Value', handles.fb.sl_extremity);
set(handles.bredit4,'String',num2str(handles.fb.sl_extremity));
set(handles.brslider3, 'Max', 1-2*handles.fb.sl_extremity+0.001);
set_slider(handles.brslider3);

slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function brslider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brslider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function bredit4_Callback(hObject, eventdata, handles)
% hObject    handle to bredit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bredit4 as text
%        str2double(get(hObject,'String')) returns contents of bredit4 as a double
handles.fb.sl_extremity = str2double(get(hObject,'String'));
handles.fb.sl_extremity = slider_chk('Ratio of one extremity to the whole slope', floor(handles.fb.sl_extremity/0.05+0.001)*0.05, handles.brslider4);
set(handles.bredit4,'String',num2str(handles.fb.sl_extremity));
set(handles.brslider4,'Value',handles.fb.sl_extremity);

slope_draw(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bredit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bredit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_method.
function pop_method_Callback(hObject, eventdata, handles)
% hObject    handle to pop_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_method
handles.fb.method = get(hObject,'Value');
handles = switch_mode(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_shaping.
function chk_shaping_Callback(hObject, eventdata, handles)
% hObject    handle to chk_shaping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_shaping
handles.fb.shaping_yn = get(hObject,'Value');
handles = switch_mode(handles);
% Update handles structure
guidata(hObject, handles);


% using function to (re)draw slope
function slope_draw(handles)
ind = 1;
x = handles.fb.max_neg-0.5:0.1:handles.fb.max_pos+0.5;
for i = x
    if handles.fb.method == 2
        res(ind) = slope_fun(i, 21, handles.fb.max_neg, handles.fb.max_pos,...
            handles.fb.break_low, handles.fb.break_high,...
            handles.fb.sl_middle, handles.fb.sl_extremity);
    else
        res(ind) = slope_fun(i, 21, handles.fb.max_neg, handles.fb.max_pos);
    end
    ind = ind +1;
end
% figure
% handles.axes1 = axes;
plot(handles.axes1,x,res,':+r','MarkerSize',4,'LineWidth',1.5);
grid on
xlabel(handles.axes1,'Normalized activation / %');
ylabel(handles.axes1,'Feedback Color');
axis([min(x) max(x) min(res) max(res)]);
if handles.fb.method == 3
    set(gca,'XTick',[handles.fb.max_neg, -handles.fb.break_high, -handles.fb.break_low,...
        handles.fb.break_low, handles.fb.break_high, handles.fb.max_pos ]);
end
set(gca, 'YTick', 1:4:21);

% using function to (re)draw slope
function res = slope_fun(val, deg, p_min, p_max, br_l, br_h, sl_mid, sl_ext)
if val >= p_max
    res = deg;
elseif val <= p_min
    res = 1;
else
    if nargin > 4
        gr_mid = (deg-1)*sl_mid/(2*br_l);
        gr_fast = (deg-1)*(0.5-sl_ext-0.5*sl_mid)/(br_h-br_l);
        gr_slow_d = (deg-1)*sl_ext/(-br_h-p_min);
        gr_slow_a = (deg-1)*sl_ext/(p_max-br_h);
        if abs(val) < br_l % middle part
            res = round(val*gr_mid + 1 + (deg-1)*0.5);
        elseif abs(val) < br_h % moderate (de)active
            if val>0
                res = round((val-br_l)*gr_fast + 1 + (deg-1)*(0.5 + 0.5*sl_mid));
            else
                res = round((val+br_h)*gr_fast + 1 + (deg-1)*(sl_ext));
            end
        else % extreme (de)active
            if val>0
                res = round((val-br_h)*gr_slow_a + 1 + (deg-1)*(1-sl_ext));
            else
                res = round((val-p_min)*gr_slow_d + 1);
            end
        end
    else
        gr = (deg-1)/(p_max - p_min);
        res = round((val-p_min)*gr + 1);
    end
end

% check if value is in the range of the slider
function val = slider_chk(txt, val, hSlider)
slidermin = get(hSlider, 'Min');
slidermax = get(hSlider, 'Max');
if val <= slidermin
    val = slidermin;
    questdlg(sprintf('Allowed range for %s values is %s to %s. \n Value has been set to %s',...
        txt,...
        num2str(slidermin),num2str(slidermax),...
        num2str(slidermin)),'User Error','OK','OK');
end
if val >= slidermax
    val = slidermax;
    questdlg(sprintf('Allowed range for %s values is %s to %s. \n Value has been set to %s',...
        txt,...
        num2str(slidermin),num2str(slidermax),...
        num2str(slidermax)),'User Error','OK','OK');
end

% set SliderStep to keep the original settings
function set_slider(hSlider)
sl_step = get(hSlider, 'UserData');
sl_rng = get(hSlider, 'Max') - get(hSlider, 'Min');
for i = 1:2
    sl_step(i) = sl_step(i)/sl_rng;
end
set(hSlider, 'SliderStep', sl_step);

function handles = switch_mode(handles)
vis={'off','on'};
set(handles.slpanel, 'Visible', vis{(1-handles.fb.shaping_yn)+1});
set(handles.brpanel, 'Visible', vis{(1-handles.fb.shaping_yn)*(handles.fb.method-1)+1});
% graphical representation of the relationship between normalized
% activation and feedback clor
slope_draw(handles);
