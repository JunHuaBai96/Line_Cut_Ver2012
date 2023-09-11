function varargout = GUI_bildDrehen(varargin)
% GUI_BILDDREHEN MENU_HILFE code for GUI_bildDrehen.fig
%   vargout{1} = abbruch => boolean, gibt an, wie das Fenster geschlossen
%   wurde


% Edit the above text to modify the response to help GUI_bildDrehen

% Last Modified by GUIDE v2.5 27-Jan-2012 23:24:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_bildDrehen_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_bildDrehen_OutputFcn, ...
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


% --- Executes just before GUI_bildDrehen is made visible.
function GUI_bildDrehen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MENU_HILFE
% handles    structure with handles and user data (see GUIDATA)
% varargin   input arguments: 
%               1: filename
%               2: data directory

handles.filename = varargin{1};
% handles.filein = varargin{2};
% handles.fileout = varargin{3};
handles.method = 'nearest';
handles.bbox = 'loose';

handles.winkel = 0;
handles.abbruch = 0;

% show picture unrotated
BildDrehen(hObject, handles, 0)
% Choose default command line output for GUI_bildDrehen
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_bildDrehen wait for user response (see UIRESUME)
%set(hObject,'WindowStyle','modal','MenuBar','figure');
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_bildDrehen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MENU_HILFE
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = handles.abbruch;
% Hint: delete(hObject) closes the figure
delete(handles.figure1);


% --- turns the picture by the given angle
function BildDrehen(hObject, handles, winkel)
%     cd(handles.filein)
    I = imread(handles.filename);
    B = imrotate(I,winkel,handles.method,handles.bbox);
    imshow(B)
    set(handles.EDIT_winkel,'TooltipString',['Methode: ' handles.method '; Schnitt: ' handles.bbox]);
    handles.winkel = winkel;
    guidata(hObject, handles);


function SLIDER_winkel_Callback(hObject, eventdata, handles)
    winkel = get(handles.SLIDER_winkel,'Value');
    set(handles.EDIT_winkel,'String',num2str(winkel));
    BildDrehen(hObject,handles, winkel);


function SLIDER_winkel_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function EDIT_winkel_Callback(hObject, eventdata, handles)
    winkel = str2num(get(handles.EDIT_winkel,'String'));
    if winkel < -180
        winkel = -180;
        set(handles.EDIT_winkel,'String',num2str(winkel));
    end
    if winkel > 180
        winkel = 180;
        set(handles.EDIT_winkel,'String',num2str(winkel));
    end
    set(handles.SLIDER_winkel,'Value',winkel);
    BildDrehen(hObject, handles, winkel);


function EDIT_winkel_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % save picture
%     cd(handles.filein)
    I = imread(handles.filename);
    B = imrotate(I,handles.winkel);
    [parentFolder, name, ext] = fileparts(handles.filename);
%     cd(handles.fileout)
    imwrite(B,[parentFolder filesep name '_turned' ext]);
    
    uiresume(handles.figure1); % nach uiresume wird automatisch die OutputFct ausgeführt




function menu_datei_Callback(hObject, eventdata, handles)


function menu_datei_speichern_Callback(hObject, eventdata, handles)
figure1_CloseRequestFcn(hObject, eventdata, handles)

function menu_datei_abbrechen_Callback(hObject, eventdata, handles)
handles.abbruch = 1;
guidata(hObject, handles);

uiresume(handles.figure1); % nach uiresume wird automatisch die OutputFct ausgeführt


function menu_methode_Callback(hObject, eventdata, handles)


function menu_bild_Callback(hObject, eventdata, handles)


function menu_bild_crop_Callback(hObject, eventdata, handles)
    handles.bbox = 'crop';
    set(handles.menu_bild_crop,'Checked','on');
    set(handles.menu_bild_loose,'Checked','off');
    guidata(hObject, handles);
    BildDrehen(hObject, handles, str2num(get(handles.EDIT_winkel,'String')));


function menu_bild_loose_Callback(hObject, eventdata, handles)
    handles.bbox = 'loose';
    set(handles.menu_bild_crop,'Checked','off');
    set(handles.menu_bild_loose,'Checked','on');
    guidata(hObject, handles);
    BildDrehen(hObject, handles, str2num(get(handles.EDIT_winkel,'String')));

function menu_methode_nearest_Callback(hObject, eventdata, handles)
    handles.method = 'nearest';
    set(handles.menu_methode_nearest,'Checked','on');
    set(handles.menu_methode_bilinear,'Checked','off');
    set(handles.menu_methode_bicubic,'Checked','off');
    guidata(hObject, handles);
    BildDrehen(hObject, handles, str2num(get(handles.EDIT_winkel,'String')));

function menu_methode_bilinear_Callback(hObject, eventdata, handles)
    handles.method = 'bilinear';
    set(handles.menu_methode_nearest,'Checked','off');
    set(handles.menu_methode_bilinear,'Checked','on');
    set(handles.menu_methode_bicubic,'Checked','off');
    guidata(hObject, handles);
    BildDrehen(hObject, handles, str2num(get(handles.EDIT_winkel,'String')));

function menu_methode_bicubic_Callback(hObject, eventdata, handles)
    handles.method = 'bicubic';
    set(handles.menu_methode_nearest,'Checked','off');
    set(handles.menu_methode_bilinear,'Checked','off');
    set(handles.menu_methode_bicubic,'Checked','on');
    guidata(hObject, handles);
    BildDrehen(hObject, handles, str2num(get(handles.EDIT_winkel,'String')));


function menu_hilfe_Callback(hObject, eventdata, handles)


function menu_hilfe_doc_Callback(hObject, eventdata, handles)
    doc imrotate


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
    pos_fig = get(handles.figure1,'Position');
    % AXES_bild
    pos_main = get(handles.AXES_bild,'Position');
    pos_main(3) = pos_fig(3) - pos_main(1) - 75;
    pos_main(4) = pos_fig(4) - 2*pos_main(2);
    set(handles.AXES_bild,'Position',pos_main);
    % SLIDER_winkel
    pos_slider = get(handles.SLIDER_winkel,'Position');   
    pos_slider(1) = pos_main(1) + pos_main(3) + 1;
    pos_slider(4) = pos_main(4);
    set(handles.SLIDER_winkel,'Position',pos_slider);
    % scale-texts + EDIT_winkel
    pos_text2 = get(handles.text2,'Position');
    pos_text3 = get(handles.text3,'Position');
    pos_edit = get(handles.EDIT_winkel,'Position');
    pos_text2(1) = pos_slider(1) + 22;
    pos_text2(2) = pos_slider(4) + pos_slider(2) - pos_text2(4);
    pos_text3(1) = pos_text2(1);
    pos_edit(1) = pos_text2(1);
    pos_edit(2) = round(pos_slider(4)/2) + pos_slider(2) - round(pos_edit(4)/2);
    set(handles.text2,'Position',pos_text2);
    set(handles.text3,'Position',pos_text3);
    set(handles.EDIT_winkel,'Position',pos_edit);
