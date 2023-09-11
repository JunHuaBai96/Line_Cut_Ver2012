%% Grain size line cut analysis - GUI_lincut.m
% Abstract:  
%   This program allows you to analyze the size of grains in a
%   micrograph with the 'line cut' method arranged in a user-friendly GUI. 
%   After loading the micrograph the program puts lines on the surface. Now
%   you have to use the cursor to click on the intercept of the lines with
%   the grain boundaries. Concluding you get an editable and savable 
%   histogram and a txt-file containing the length of the grains.
%   You can also analyze existing txt-files to get the histogram (including
%   lognormal distribution fitting) or an empirical cumulative distribution
%   function plot of different micrographs and you can compare them in one 
%   chart. In addition you get a lot of features (e.g. rotate image) and
%   fully control about many settings.
%   For more information, watch the screencast:
%   <http://www.screencast.com/t/O9kWfH9Hwn>
%   Alternative on YouTube:
%   <http://www.youtube.com/playlist?list=PL08596CB91051E91B>
%
%   Hint: GUI appearence is optimized for Windows 7 Aero Style! The style
%   of GUI elements is not checked on other OS layouts!
%
% Version:          2.0
% Release date:     2012-02-26
% Author:           Matthias Funk, Sven Meister
% Matlab Version:   R2011b
%
% Acknowledgements:
%   This spplication is based on the idea and code of Matthias Funk from
%   the Karlsruhe Institute of Technology (KIT), IAM-WBM, Nachwuchsgruppe 
%   für microreliability. This project was financed by DFG-SFB499N01.   
%   The lognormal distribution fitting in histogram was created by 
%   Jochen Lohmiller.
%
% 
% *Content:*
% ¯¯¯¯¯¯¯¯¯¯
% (to switch into the parts directly, klick on the name behind the colon 
%  and hit CTRL+D)
% -------------------------------------------------------------------------
%   1. GUI initalisation:       GUI_linecut_OpeningFcn
%      1.1. Close Request:      figure_CloseRequestFcn
%      1.2. Config File:        loadConfig
%
%   2. GUI appearence:          
%      2.1. Rezise:             figure_ResizeFcn
%      2.2. Show/Hide:          PB_showPlotSettings_Callback
%                               setVisibilities
%      2.3. Image/File/CDF:     zero_main_panel
%
%   3. Settings:           
%      3.1. Image:              PB_fileImage_Callback
%      3.2. File:               PB_fileFile_Callback
%      3.3. CDF:                PB_folderCdf_Callback
%      3.4. Common:             PB_fileOut_Callback  
%
%   4. Main function:
%      4.1. Start: Image:       PB_startImage_Callback
%      4.2. Start: File:        PB_startFile_Callback
%      4.3. Start: CDF:         PB_startCdf_Callback
%      4.4. Plot                plotHist
%
%   5. Menu Callbacks:          menu_file_Callback
%      5.1. File:               menu_file_new_Callback
%      5.2. Image:              menu_image_rotate_Callback
%      5.3. Settings:           menu_settings_config_show_Callback
%      5.4. Help:               menu_help_about_Callback
%
%   6. Toolbar Callbacks:       tools_save_ClickedCallback%
% -------------------------------------------------------------------------

%% most important elements in this code:
% - control flow:
%    the program is user-controlled by Callbacks of GUI elements. The user
%    takes settings and presses 'start'. Then main function routine starts.
% - handles structure:
%    stores every GUI element (made by GUIDE) and in addition every rumtime
%    setting. When ever a setting/behavior is change, the corresponding 
%    variable changes in handles structure -> nearly no direct access to 
%    GUI element properties. There are substructures to ease naming of 
%    variables e.g. 'visible' or 'pathes'.
% - variable name convention:
%    * small initial letter
%    * more words: no underscore, but initial letter of new word as capital
%      letter
%    * GUI elements: <TYPE>_<name> (Type all capital letters)

function varargout = GUI_linecut(varargin)
% GUI_LINECUT MATLAB code for GUI_linecut.fig
%      GUI_LINECUT, by itself, creates a new GUI_LINECUT or raises the existing
%      singleton*.
%
%      H = GUI_LINECUT returns the handle to a new GUI_LINECUT or the handle to
%      the existing singleton*.
%
%      GUI_LINECUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LINECUT.M with the given input arguments.
%
%      GUI_LINECUT('Property','Value',...) creates a new GUI_LINECUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_linecut_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_linecut_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_linecut

% Last Modified by GUIDE v2.5 02-Feb-2012 16:28:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_linecut_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_linecut_OutputFcn, ...
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

%-saves filepath of main_window.m to config_dir as location for the
% config-file used @loadConfig
global config_dir
FuncFile = mfilename('fullpath');
config_dir = fileparts(FuncFile); 


% --- Executes just before GUI_linecut is made visible.
function GUI_linecut_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_linecut (see VARARGIN)

    % Load data from config-file, if possible (msg contains error-Message/ empty if all right)
    [msg,handles] = loadConfig('config.txt', eventdata, handles);
    if ~isempty(msg)    % set default values, if config-load failed
        % Disp error-Message
        disp(msg);
        disp('Load default values');
        % VALUES:
        % visible
        handles.visible.image = 0;
        handles.visible.plot = 0;
        handles.visible.cdfList = 0;
        handles.visible.hints = 0;
        handles.visible.fit = 0;
        handles.visible.cdfDetails = 0;
        handles.visible.plotSettings = 1;
        handles.visible.imageSmall = 0;
        handles.visible.plotSmall = 0;
        % [handles_numbers]
        handles.AutoNewFolder=1;    % AutoCreate of Resultsfolder (boolean)
        handles.modus=1;            % modus = 1,2,3 (Image,File,CDF)
        handles.modusShown=1;       % witch modus is shown 
        handles.isStarted=0;        % indicates weather user has started action yet 
        handles.scale=1;            % scale-factor to convert length to nm
        handles.autoLimits=1;       % plot axes limits automatic/former
        handles.showFit=1;          % show/hide fitting curve in histogram
        handles.countCdf=0;         % amount of cdf-plots
        % [handles_strings]
        handles.unit='nm';          % for plot-Label
        handles.filenamesCdf='';    % selected files in CDF-Listbox
        handles.legend_cdf='';      
        % [pathes]                  % absolute file-pathes
        handles.pathes.image='';           
        handles.pathes.file='';
        handles.pathes.cdf='';
        handles.pathes.results='';
        % [edits]                   % Values of Edits with the same name
        handles.length=100;
        handles.lines=5;
        handles.LzuD=0.79;
        handles.plot=3;
        handles.cdfName='CDF1';
        % [pums]                    % Values of Pop-Up-Menus with this name
        handles.microstructure=1;
        handles.start=1;
        handles.end=1;
        handles.plotDiv=1;
        % [checkboxes]              % Values of Checkboxes with this name
        handles.crop=1;
        handles.scaleBarMarker=1;
        handles.korngrenzen=1;
        handles.cdfHold=0;
        % [cells]
        handles.legendCdf='CDF1';   % Legend calues in CDF-Legend
        % [end]
    end
    % apply config settings
    setVisibilities(hObject, eventdata, handles);
    setModus(hObject, eventdata, handles);
    handles.modus = handles.modusShown;
    setPathesToEdits(handles.figure, eventdata, handles);
    if handles.showFit
        set(handles.CM_plot_showFit,'Checked','on');
    else
        set(handles.CM_plot_showFit,'Checked','off');
    end
    set(handles.CB_resultsFolder,'Value',handles.AutoNewFolder);
    set(handles.tools_save,'Enable','off'); % disable save
    switch handles.microstructure % start/end just used in 1-phase-Systems
        case 1
            set([handles.PUM_start,handles.PUM_end],'Enable','on');
        case 2
            set([handles.PUM_start,handles.PUM_end],'Enable','off');
    end
    
    % set icons to buttons
    set([handles.PB_folderCdf,handles.PB_fileFile,handles.PB_fileImage,...      % open
        handles.PB_fileOut], 'CData',double(imread('Icons\open_icon.bmp'))/255);
    set([handles.PB_startImage,handles.PB_startFile,handles.PB_startCdf],...    % start
        'CData',double(imread('Icons\start_icon2.bmp'))/255); 
    
    % set TooltipStrings
    s_LzuD = sprintf('correction value for chord length\n \nUse e.g.:\ntwins: L/D = 1\nround grains: L/D = 0.79');
    set(handles.EDIT_LzuD,'TooltipString',s_LzuD);
        
    % Choose default command line output for GUI_linecut
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    

% --- Outputs from this function are returned to the command line.
function varargout = GUI_linecut_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % move to screen center
    movegui(handles.figure,'center');

    % Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure.
function figure_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
    a = questdlg('Really Quit?','line cut','Yes','No','Yes'); % Sichterheitsabfrage
    if strcmp(a,'Yes')
        delete(handles.figure);
    end


%% Config.txt file
% Load config-file data and save to handles structure. Applies object-
% settings to GUI-elements (e.g. 'String'-Property of edits).
function [msg,handles] = loadConfig(file, eventdata, handles)
    global config_dir
    [values,msg] = readConfigFile(config_dir,file); 
    
    if ~isempty(values)
        % visible
        visible = fieldnames(values.visible);
        for n = 1:length(visible)
            handles.visible.(char(visible(n))) = str2num(values.visible.(char(visible(n))));
        end
        % handles_numbers
        handles_numbers = fieldnames(values.handles_numbers);
        for n = 1:length(handles_numbers)
            handles.(char(handles_numbers(n))) = str2num(values.handles_numbers.(char(handles_numbers(n))));
        end
        % handles_strings
        handles_strings = fieldnames(values.handles_strings);
        for n = 1:length(handles_strings)
            handles.(char(handles_strings(n))) = char(values.handles_strings.(char(handles_strings(n))));
        end
        % pathes
        pathes = fieldnames(values.pathes);
        for n = 1:length(pathes)
            str = char(values.pathes.(char(pathes(n))));
            if strcmp(str,'n/a')  % makes pathes real empty
                handles.pathes.(char(pathes(n))) = '';
            else
                handles.pathes.(char(pathes(n))) = char(values.pathes.(char(pathes(n))));
            end
        end
        % edits
        edits = fieldnames(values.edits);
        for n = 1:length(edits)
            handles.(char(edits(n))) = str2num(values.edits.(char(edits(n))));
            set(handles.(['EDIT_' char(edits(n))]),'String',values.edits.(char(edits(n))));
        end
        % pums
        pums = fieldnames(values.pums);
        for n = 1:length(pums)
            handles.(char(pums(n))) = str2num(values.pums.(char(pums(n))));
            set(handles.(['PUM_' char(pums(n))]),'Value',str2num(values.pums.(char(pums(n)))));
        end
        % checkboxes
        checkboxes = fieldnames(values.checkboxes);
        for n = 1:length(checkboxes)
            handles.(char(checkboxes(n))) = str2num(values.checkboxes.(char(checkboxes(n))));
            set(handles.(['CB_' char(checkboxes(n))]),'Value',str2num(values.checkboxes.(char(checkboxes(n)))));
        end
        % cells
        cells = fieldnames(values.cells);
        for n = 1:length(cells)
            handles.(char(cells(n))){1} = str2num(values.cells.(char(cells(n))));
        end
    else
        msg = 'No Values found in config-file!';
    end
    
    
% scans config-file and saves keys and values in 'values'
function [values,msg] = readConfigFile(dir, filename)
    [fid,msg] = fopen([dir filesep filename]);
    if isempty(msg)
        text = textscan(fid,'%s','delimiter','=');  % txt-Datei auslesen
        fclose(fid);
        content = text{1,1};                        
        % cell; in jeder Zelle steht ein String:
        %   [seperator]
        %   Tag
        %   Key
        %   Tag
        %   Key
        %   [seperator] usw.
        k = cell2vector(strfind(content,'[')); % sucht Indices der seperator
        ind = find(k);        % speichert indices der Zellen mit seperator
        
        for n = 1:length(ind)-1
            sep = content{ind(n)}(2:end-1); % gibt Seperator-String aus
            for m = ind(n)+1:2:ind(n+1)-1
                values.(char(sep)).(char(content{m})) = char(content{m+1});
            end
        end
    else
        values = [];
    end;
        
function k = cell2vector(c)
% wenn Inhalt der Zelle 1 ist (also wenn in der Zelle ein Seperator ist),
% wird 1 in den Vektor geschrieben, sonst 0
%   c: cell
%   k: Array
    laenge = length(c);
    k=zeros(laenge,1);
    for n = 1:laenge
        if c{n}==1
            k(n)=1;
        end
    end
    
% save data to config-file:
% loads old config-Content and change settings => new file is created and
% overwrites old file
function [msg] = saveConfig(file, eventdata, handles)
    global config_dir
    [values,msg] = readConfigFile(config_dir,file);   %[config_dir sep 'languages']
    
    if ~isempty(values)
        % visible data excluded, because opening appearence should stay
        % default
        % visible (not resetet, because startingStyle should stay the same)
%         visible = fieldnames(values.visible);
%         for n = 1:length(visible)
%             values.visible.(char(visible(n))) = num2str(handles.visible.(char(visible(n))));
%         end
        % handles_numbers
        handles_numbers = fieldnames(values.handles_numbers);
        for n = 1:length(handles_numbers)
            values.handles_numbers.(char(handles_numbers(n))) = num2str(handles.(char(handles_numbers(n))));
        end
        values.handles_numbers.countCdf = 0;
        % handles_strings
        handles_strings = fieldnames(values.handles_strings);
        for n = 1:length(handles_strings)
            values.handles_strings.(char(handles_strings(n))) = handles.(char(handles_strings(n)));
        end
        values.handles_strings.filenamesCdf = 'n/a';
        % pathes
        pathes = fieldnames(values.pathes);
        for n = 1:length(pathes)
            if isempty(handles.pathes.(char(pathes{n})))  % makes pathes real empty
                values.pathes.(char(pathes{n})) = 'n/a';
            else
                values.pathes.(char(pathes{n})) = handles.pathes.(char(pathes{n}));
            end
        end
        % edits
        edits = fieldnames(values.edits);
        for n = 1:length(edits)
            values.edits.(char(edits(n))) = num2str(handles.(char(edits(n))));
        end
        values.edits.cdfName = 'CDF1';
        % pums
        pums = fieldnames(values.pums);
        for n = 1:length(pums)
            values.pums.(char(pums(n))) = num2str(handles.(char(pums(n))));
        end
        % checkboxes
        checkboxes = fieldnames(values.checkboxes);
        for n = 1:length(checkboxes)
            values.checkboxes.(char(checkboxes(n))) = num2str(handles.(char(checkboxes(n))));
        end
        % cells
        cells = fieldnames(values.cells);
        for n = 1:length(cells)
            values.cells.(char(cells(n))) = num2str(handles.(char(cells(n))){1});
        end
        values.cells.legendCdf='CDF1';
        msg = writeConfigFile([config_dir filesep 'configTemp.txt'],values);
        if isempty(msg)
            copyfile([config_dir filesep 'configTemp.txt'],[config_dir filesep 'config.txt'],'f');
            delete([config_dir filesep 'configTemp.txt']);
        end
    else
        msg = 'No Values found in config-file!';
    end
    
function [msg] = writeConfigFile(file,values)
	[p,n,e] = fileparts(file);
    if isdir(p)                 
        % cell; in jeder Zelle steht ein String:
        %   [seperator]
        %   Tag
        %   Key
        %   Tag
        %   Key
        %   [seperator] usw.
        names = fieldnames(values);
        z = 0;
        for n = 1:length(names)
            s{n+z,1} = ['[' names{n} ']'];
            name = fieldnames(values.(names{n}));
            for m = 1:length(name)
                s{n+z+m,1} = [char(name{m}) '=' char(values.(names{n}).(name{m}))];
            end    
            z=z + m;
        end
        dlmwrite(file,s{1,1},'Delimiter','');
        for n = 2:size(s,1)
            dlmwrite(file,s{n,1},'Delimiter','','-append');
        end
        dlmwrite(file,'[end]','Delimiter','','-append');
        msg = '';
    else
        msg = 'error: dir not found';
    end;
    
    
% puts pathes from config-file to edits
function setPathesToEdits(hObject, eventdata, handles)
    hp = handles.pathes;
    s = handles.modusShown;
    % Image
    if (s==1) && ~isempty(hp.image)
        PB_fileImage_Callback(handles.menu_image_rotate, eventdata, handles)
    end
    % File
    if ~isempty(hp.file)
        PB_fileFile_Callback(hObject, eventdata, handles)
    end
%     % CDF %% not good, because click on PB performs action => either
%     image or CDF...
%     if (s==3) && ~isempty(hp.cdf)
%         PB_folderCdf_Callback(hObject, eventdata, handles)
%     end
    % CDF
    if ~isempty(hp.results)
        PB_fileOut_Callback(handles.PB_newFolder, eventdata, handles)
    end
    

%% Resize -----------------------------------------------------------------
% controlls resize behavior of GUI elements
function figure_ResizeFcn(hObject, eventdata, handles)
    pos_fig = get(handles.figure,'Position');
    % PANEL_main
    pos_main = get(handles.PANEL_main,'Position');
    pos_main(2) = pos_fig(4) - pos_main(4);
    set(handles.PANEL_main,'Position',pos_main);
    % PANEL_hints + hiddenHints
    pos_hints = get(handles.PANEL_hints,'Position');
    pos_hiddenHints = get(handles.PANEL_hiddenHints,'Position');    
    pos_hints(1) = pos_fig(3) - pos_hints(3);
    pos_hints(2) = pos_fig(4) - pos_hints(4);
    pos_hiddenHints(1) = pos_fig(3) - pos_hiddenHints(3);
    pos_hiddenHints(2) = pos_hints(2);
    set(handles.PANEL_hints,'Position',pos_hints);
    set(handles.PANEL_hiddenHints,'Position',pos_hiddenHints);
    % PANEL_cdfDetails + fit + hiddenPlotDetails
    pos_cdfDetails = get(handles.PANEL_cdfDetails,'Position');
    pos_fit = get(handles.PANEL_fit,'Position');
    pos_hiddenPlotDetails = get(handles.PANEL_hiddenPlotDetails,'Position');
    pos_cdfDetails(1) = pos_fig(3) - pos_cdfDetails(3);
    pos_fit(1) = pos_cdfDetails(1);
    pos_hiddenPlotDetails(1) = pos_fig(3) - pos_hiddenPlotDetails(3);
    set(handles.PANEL_cdfDetails,'Position',pos_cdfDetails);
    set(handles.PANEL_fit,'Position',pos_fit);
    set(handles.PANEL_hiddenPlotDetails,'Position',pos_hiddenPlotDetails);
    % AXES_image
    RESIZE_axes_image(hObject, eventdata, handles);
    % PANEL_plot
    RESIZE_panel_plot(hObject, eventdata, handles);
    % PANEL_cdfList
    RESIZE_panel_cdfList(hObject, eventdata, handles);


function RESIZE_axes_image(hObject, eventdata, handles)
    pos_fig = get(handles.figure,'Position');
    pos = get(handles.AXES_image,'Position');
    hv = handles.visible;
    if hv.hints + hv.fit + hv.cdfDetails == 0
        dx_rechts = 40; % nach rechts ausdehnen, wenn beide seitlichen Boxen eingeklappt sind
    else
        dx_rechts = 210;
    end
    if hv.imageSmall == 1
        dy = round(0.75 * pos_fig(4));  % image auf 25% der Fensterhöhe skaliert
    elseif hv.plot == 0
        dy = 5;
    else
        dy = round(0.3 * pos_fig(4));  % image auf 70% der Fensterhöhe skaliert
    end
    pos(2) = dy;
    pos(4) = pos_fig(4) - dy;
    pos(3) = pos_fig(3) - pos(1) - dx_rechts;
    set(handles.AXES_image,'Position',pos);
    

function RESIZE_panel_plot(hObject, eventdata, handles)
    pos_fig = get(handles.figure,'Position');
    % PANEL
    pos_panel = get(handles.PANEL_plot,'Position');
    hv = handles.visible;
    if hv.hints + hv.fit + hv.cdfDetails == 0
        dx_rechts = 40; % nach rechts ausdehnen, wenn beide seitlichen Boxen eingeklappt sind
    else
        dx_rechts = 210;
    end
    if hv.plotSmall == 1
        dy = round(0.75 * pos_fig(4));  % plot auf 25% der Fensterhöhe skaliert
    elseif (hv.image == 0) && (hv.cdfList == 0)
        dy = 5;
    else
        dy = round(0.3 * pos_fig(4));  % plot auf 70% der Fensterhöhe skaliert
    end
    pos_panel(4) = pos_fig(4) - dy;
    pos_panel(3) = pos_fig(3) - pos_panel(1) - dx_rechts;
    set(handles.PANEL_plot,'Position',pos_panel);
    % AXES
    pos_axes = get(handles.AXES_plot,'Position');
    pos_axes(3) = pos_panel(3) - pos_axes(1) - 15;
    pos_axes(4) = pos_panel(4) - pos_axes(2) - 30;    
    set(handles.AXES_plot,'Position',pos_axes);
    % X-LIMIT
    pos_xlim = get(handles.EDIT_XLim_max,'Position');
    pos_xlim(1) = pos_axes(1) + pos_axes(3) - pos_xlim(3);
    set(handles.EDIT_XLim_max,'Position',pos_xlim);
    % Y-LIMIT
    pos_ylim = get(handles.EDIT_YLim_max,'Position');
    pos_ylim(2) = pos_axes(2) + pos_axes(4) - pos_ylim(4);
    set(handles.EDIT_YLim_max,'Position',pos_ylim);
 
    
function RESIZE_panel_cdfList(hObject, eventdata, handles)
    pos_fig = get(handles.figure,'Position');
    % PANEL
    pos_panel = get(handles.PANEL_cdfList,'Position');
    hv = handles.visible;
    if hv.plotSmall == 0
        dy = round(0.72 * pos_fig(4));  % panel auf 28% der Fensterhöhe skaliert
    else
        dy = round(0.3 * pos_fig(4));  % panel auf 70% der Fensterhöhe skaliert
    end
    pos_panel(2) = dy;
    pos_panel(4) = pos_fig(4) - dy;
    set(handles.PANEL_cdfList,'Position',pos_panel);
    % LISTBOX
    pos_list = get(handles.LIST_cdf,'Position');
    pos_list(4) = pos_panel(4) - pos_list(2) - 91;    
    set(handles.LIST_cdf,'Position',pos_list);
    % TITLE
    pos_title = get(handles.TEXT_cdfTitle,'Position');
    pos_title(2) = pos_panel(4) - pos_title(4) - 1;
    set(handles.TEXT_cdfTitle,'Position',pos_title);
    % Y-LIMIT
    pos_text = get(handles.TEXT_cdf1,'Position');
    pos_text(2) = pos_panel(4) - pos_text(4) - 18;
    set(handles.TEXT_cdf1,'Position',pos_text);
    

%% Show/Hide Panels -------------------------------------------------------
% Plot Settings
function PB_showPlotSettings_Callback(hObject, eventdata, handles)
    set(handles.PANEL_plotSettings,'Visible','on');
    set(handles.PANEL_hiddenPlotSettings,'Visible','off');
function PB_hidePlotSettings_Callback(hObject, eventdata, handles)
    set(handles.PANEL_plotSettings,'Visible','off');
    set(handles.PANEL_hiddenPlotSettings,'Visible','on');
    
% Hints
function PB_showHints_Callback(hObject, eventdata, handles)
    set(handles.PANEL_hints,'Visible','on');
    set(handles.PANEL_hiddenHints,'Visible','off');
    handles.visible.hints = 1;
    RESIZE_axes_image(hObject, eventdata, handles);
    RESIZE_panel_plot(hObject, eventdata, handles);
    guidata(hObject, handles);
function PB_hideHints_Callback(hObject, eventdata, handles)
    set(handles.PANEL_hints,'Visible','off');
    set(handles.PANEL_hiddenHints,'Visible','on');
    handles.visible.hints = 0;
    RESIZE_axes_image(hObject, eventdata, handles);
    RESIZE_panel_plot(hObject, eventdata, handles);
    guidata(hObject, handles);
  
% Plot Details
function handles = PB_showPlotDetails_Callback(hObject, eventdata, handles)
    if handles.modus == 3
        set(handles.PANEL_cdfDetails,'Visible','on');
        handles.visible.cdfDetails = 1;
    else
        set(handles.PANEL_fit,'Visible','on');
        handles.visible.fit = 1;
    end
    set(handles.PANEL_hiddenPlotDetails,'Visible','off');
    RESIZE_axes_image(hObject, eventdata, handles);
    RESIZE_panel_plot(hObject, eventdata, handles);
    guidata(hObject, handles);
function handles = PB_hideFit_Callback(hObject, eventdata, handles)
    set(handles.PANEL_fit,'Visible','off');
    set(handles.PANEL_hiddenPlotDetails,'Visible','on');
    handles.visible.fit = 0;
    RESIZE_axes_image(hObject, eventdata, handles);
    RESIZE_panel_plot(hObject, eventdata, handles);
    guidata(hObject, handles);
function PB_hideCdfDetails_Callback(hObject, eventdata, handles)
    set(handles.PANEL_cdfDetails,'Visible','off');
    set(handles.PANEL_hiddenPlotDetails,'Visible','on');
    handles.visible.cdfDetails = 0;
    RESIZE_axes_image(hObject, eventdata, handles);
    RESIZE_panel_plot(hObject, eventdata, handles);
    guidata(hObject, handles);
    
% set visibilities as saved in handles.visible
function setVisibilities(hObject, eventdata, handles)
    hv = handles.visible;
    if hv.image
         set(handles.AXES_image,'Visible','on');
    else set(handles.AXES_image,'Visible','off');
         cla(handles.AXES_image);
    end;
    if hv.plot
         set(handles.PANEL_plot,'Visible','on');
    else set(handles.PANEL_plot,'Visible','off'); 
    end;
    if hv.cdfList
         set(handles.PANEL_cdfList,'Visible','on');
    else set(handles.PANEL_cdfList,'Visible','off'); 
    end;
    if hv.hints
         set(handles.PANEL_hints,'Visible','on');
         set(handles.PANEL_hiddenHints,'Visible','off');
    else set(handles.PANEL_hints,'Visible','off');
         set(handles.PANEL_hiddenHints,'Visible','on');   
    end;
    if hv.fit
         set(handles.PANEL_fit,'Visible','on');
         set(handles.PANEL_hiddenPlotDetails,'Visible','off');
    else set(handles.PANEL_fit,'Visible','off'); 
    end;
    if hv.cdfDetails
         set(handles.PANEL_cdfDetails,'Visible','on');
         set(handles.PANEL_hiddenPlotDetails,'Visible','off');
    else set(handles.PANEL_cdfDetails,'Visible','off'); 
    end;
    if ~hv.fit && ~hv.cdfDetails
         set(handles.PANEL_hiddenPlotDetails,'Visible','on');
    end;
    if hv.plotSettings
         set(handles.PANEL_plotSettings,'Visible','on');
         set(handles.PANEL_hiddenPlotSettings,'Visible','off');
    else set(handles.PANEL_plotSettings,'Visible','off'); 
         set(handles.PANEL_hiddenPlotSettings,'Visible','on');
    end;    
    guidata(hObject, handles);
    
    
%% Switch between Image/File/CDF ------------------------------------------
function zero_main_panel(hObject, eventdata, handles)
    set([handles.TB_image,handles.TB_file,handles.TB_cdf],'Value',0);
    set([handles.PANEL_image,handles.PANEL_file,handles.PANEL_cdf],'Visible','off');
%     guidata(hObject, handles);

function TB_image_Callback(hObject, eventdata, handles)
    zero_main_panel(hObject, eventdata, handles);
    set(handles.TB_image,'Value',1);
    set(handles.PANEL_image,'Visible','on');
    handles.modusShown = 1;
    guidata(hObject, handles);

function TB_file_Callback(hObject, eventdata, handles)
    zero_main_panel(hObject, eventdata, handles);
    set(handles.TB_file,'Value',1);
    set(handles.PANEL_file,'Visible','on');
    handles.modusShown = 2;
    guidata(hObject, handles);

function TB_cdf_Callback(hObject, eventdata, handles)
    zero_main_panel(hObject, eventdata, handles);
    set(handles.TB_cdf,'Value',1);
    set(handles.PANEL_cdf,'Visible','on');
    handles.modusShown = 3;
    guidata(hObject, handles);
    
function setModus(hObject, eventdata, handles)
    switch handles.modusShown
        case 1
            TB_image_Callback(handles.TB_image, eventdata, handles);
        case 2
            TB_file_Callback(handles.TB_file, eventdata, handles);
        case 3
            TB_cdf_Callback(handles.TB_cdf, eventdata, handles);
    end

    
%% Settings: Image --------------------------------------------------------
% (in order of appearance on GUI)
function PB_fileImage_Callback(hObject, eventdata, handles)
% if pathname is longer then 12 chars, it will be cut and seperated by ...
    if hObject == handles.menu_image_rotate % after rotating an image
        [p,n,e] = fileparts(handles.pathes.image);
        filename = [n e];
        pathname = [p filesep];
    elseif hObject == handles.CM_pathesImage % after deletion by cont-menu
        pathname = '';
    else % this is the normal Callback action
        [p,n,e] = fileparts(handles.pathes.image);
        [filename,pathname] = uigetfile({'*.jpg;*.jpeg;*.bmp;*.png;*.tif;*.tiff','Image Files (*.jpg,*.bmp,*.png,*.tif)'; '*.*',  'All Files (*.*)'},'select an image file',p);
    end
    if ischar(pathname) && isdir(pathname)
        handles.pathes.image = [pathname filename];
        if length(pathname) > 12
            dots = ['...' filesep];
        else
            dots = '';
        end
        set(handles.EDIT_fileImage,'String',[pathname(1:min(end,12)) dots filename],...
            'TooltipString',[pathname filename]);
        % show image in AXES_image
        handles.visible.image = 1;
        handles.visible.imageSmall = 0;
        handles.visible.plotSmall = 1;
        RESIZE_axes_image(hObject, eventdata, handles);
        RESIZE_panel_plot(hObject, eventdata, handles);
        set([handles.AXES_image],'Visible','on');
        axes(handles.AXES_image);
        I = imread([pathname filename]);
        imshow(I,'InitialMagnification',100);
    else
        % isempty == true after deletion of path in Edit
        % isempty == false after canceling input-Dialog (pathname='0')
        if isempty(pathname)
            set(handles.EDIT_fileImage,'String','',...
                'TooltipString','Select an image file.');
        end
    end
    guidata(hObject, handles);
    
function EDIT_length_Callback(hObject, eventdata, handles)
    val = str2num(get(hObject,'String'));
    if val>0  % only positive non-zero values possible
        handles.length = val;
    else
        set(hObject,'String',num2str(handles.length));
    end;
    guidata(hObject, handles);
    
function handles = PUM_length_Callback(hObject, eventdata, handles)
    handles = PUM_scaleCdf_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);
    
function EDIT_lines_Callback(hObject, eventdata, handles)
    val = str2num(get(hObject,'String'));
    if val>0  % only positive non-zero values possible
        handles.lines = val;
    else
        set(hObject,'String',num2str(handles.lines));
    end;
    guidata(hObject, handles);
    
function PUM_microstructure_Callback(hObject, eventdata, handles)
    handles.microstructure = get(hObject,'Value');
    switch handles.microstructure 
        case 1
            set([handles.PUM_start,handles.PUM_end],'Enable','on');
        case 2
            set([handles.PUM_start,handles.PUM_end],'Enable','off');
    end
    guidata(hObject, handles);
    
function EDIT_LzuD_Callback(hObject, eventdata, handles)
    handles.LzuD = str2num(get(hObject,'String'));
    guidata(hObject, handles);  
    
function PUM_start_Callback(hObject, eventdata, handles)
    val = get(hObject, 'Value');
    handles.start = val;
    handles.end = val;
    set(handles.PUM_end,'Value',val);
    guidata(hObject, handles);

function PUM_end_Callback(hObject, eventdata, handles)
    handles.end = get(hObject, 'Value');
    guidata(hObject, handles);
 
% crop image? y/n
function CB_crop_Callback(hObject, eventdata, handles)
    handles.crop = get(hObject, 'Value');
    guidata(hObject, handles);
        
% ask whether scalebar is marked correctly? y/n
function CB_scaleBarMarker_Callback(hObject, eventdata, handles)
    handles.scaleBarMarker = get(hObject, 'Value');
    guidata(hObject, handles);
    
% NOT USED    
function CB_bildExtern_Callback(hObject, eventdata, handles)
% NOT USED - exists from old version, maybe will be implemented later
%     switch get(hObject,'Value')
%         case 0
%             handles.massbalken  = 0;
%             handles.korngrenzen = 0;  <= RENAME IF USED!!
%         case 1
%             a = dialog_bildExtern;
%             handles.massbalken = a(1);
%             handles.korngrenzen = a(2);
%             if (a(1) == 0) && (a(2) == 0)
%                 set(handles.CB_bildExtern,'Value',0);
%             end
%     end
%     guidata(hObject, handles);
    
function CB_korngrenzen_Callback(hObject, eventdata, handles)
    handles.korngrenzen = get(hObject, 'Value');
    guidata(hObject, handles);
    
    
%% Settings: File --------------------------------------------------------
function PB_fileFile_Callback(hObject, eventdata, handles)
% if pathname is longer then 8 chars, it will be cut and seperated by ...
    if hObject == handles.figure % after loading config
        [p,n,e] = fileparts(handles.pathes.file);
        filename = [n e];
        pathname = [p filesep];
    elseif hObject == handles.CM_pathesFile
        pathname = ''; 
    else % this is the normal Callback action
        [p,n,e] = fileparts(handles.pathes.file);
        [filename,pathname] = uigetfile({'*.dat; *.txt'},'select a chordlength file',p);
    end
    if ischar(pathname) && isdir(pathname)
        handles.pathes.file = [pathname filename];
        if length(pathname) > 8
            dots = ['...' filesep];
        else
            dots = '';
        end
        set(handles.EDIT_fileFile,'String',[pathname(1:min(end,12)) dots filename],...
            'TooltipString',[pathname filename]);
    else
        if isempty(pathname)
            set(handles.EDIT_fileFile,'String','',...
                'TooltipString','Select a chordlength file.');
        end
    end
    guidata(hObject, handles);

function handles = PUM_scaleFile_Callback(hObject, eventdata, handles)
    handles = PUM_scaleCdf_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);


    
%% Settings: CDF ----------------------------------------------------------
function PB_folderCdf_Callback(hObject, eventdata, handles)
% if pathname is longer then 12 chars, it will be cut and seperated by ...
    if hObject == handles.figure % after loading config
        pathname = handles.pathes.cdf;
    elseif hObject == handles.CM_pathesCdf
        pathname = ''; 
    else  % this is the normal Callback action
        pathname = uigetdir(handles.pathes.cdf,'select source folder');
    end
    if isdir(char(pathname))
        handles.pathes.cdf = pathname;        
        [parentFolder, folder, ext] = fileparts(pathname);
        if length(parentFolder) > 12
            dots = '...';
        else
            dots = '';
        end
        set(handles.EDIT_folderCdf,'String',[parentFolder(1:min(end,12)) dots filesep folder],...
            'TooltipString',pathname);        
        %---Dateien in Listbox laden:/set filenames to listbox:------------
        names = '';
        D = dir(pathname);  % Index 3 ist der erste Datei/Ordner-Name
        lengthD = size(D,1);
        for i=3:lengthD      % so gelöst weil: Wenn keine Datei vorhanden ist, wird die Schleife nicht ausgeführt ==> keine Error-Gefahr
            if i==3
                names = char(D(i).name);
            else
                names = char(names,D(i).name);
            end           
        end
        set(handles.LIST_cdf,'String',names,'Value',1); 
        LIST_cdf_Callback(handles.LIST_cdf, eventdata, handles)
        if handles.countCdf <= 0
            set(handles.CB_cdfHold,'Visible','off'); 
        end
        % set appearance of GUI for "CDF"
        hv = handles.visible;    
        hv.hints = 0;
        hv.image = 0;
        hv.cdfList = 1;
        hv.imageSmall=1;
        hv.plotSmall=1;
        hv.plotSettings=0;    
        handles.visible = hv;
        setVisibilities(hObject, eventdata, handles);
        figure_ResizeFcn(hObject, eventdata, handles);
        % ---------------------------------------------------------------------
    else
        if isempty(pathname)
            set(handles.EDIT_folderCdf,'String','',...
                'TooltipString','Choose a folder with your data.');
        end
    end
    guidata(hObject, handles);
    
function handles = PUM_scaleCdf_Callback(hObject, eventdata, handles)
    val = get(hObject,'Value');
    handles.scale = 10^((val-1)*3);
    label = get(hObject,'String');
    handles.unit = char(label(get(hObject,'Value')));
    guidata(hObject, handles);

% shows how many files are selected
function LIST_cdf_Callback(hObject, eventdata, handles)
    y = size(get(hObject,'Value'),2);
    set(handles.EDIT_amountCdf,'String',num2str(y));
    guidata(hObject, handles);

function CB_cdfHold_Callback(hObject, eventdata, handles)
    handles.cdfHold = get(hObject, 'Value');
    handles.AutoNewFolder = 0;
    set(handles.PB_newFolder,'Enable','on');
    set(handles.CB_resultsFolder,'Value',0);
    guidata(hObject, handles);
    
function EDIT_cdfName_Callback(hObject, eventdata, handles)
    leg = handles.legendCdf;
    leg{handles.countCdf} = get(hObject,'String');
    hleg = legend(leg,'Location','SouthEast');
    set(hleg,'FontSize',8)
    handles.legendCdf = leg;
    guidata(hObject, handles);
    
    
%% Settings: common -------------------------------------------------------
% Results folder
function PB_fileOut_Callback(hObject, eventdata, handles)
% select results folder
% if pathname is longer then 5 chars, it will be cut and seperated by ...
    if hObject == handles.PB_newFolder % after creating a results folder
        pathname = handles.pathes.results;
    elseif hObject == handles.CM_pathesResults
        pathname = ''; 
    else  % this is the normal Callback action        
        pathname = uigetdir(handles.pathes.results,'select results folder');
        handles.AutoNewFolder = 0;
        set(handles.CB_resultsFolder,'Value',0);
    end
    if isdir(char(pathname))
        handles.pathes.results = pathname;
        [parentFolder, folder, ext] = fileparts(pathname);
        if length(parentFolder) > 5
            dots = '..';
        else
            dots = '';
        end
        set(handles.EDIT_fileOut,'String',[parentFolder(1:min(end,5)) dots filesep folder],...
            'TooltipString',pathname);        
    else
        if isempty(pathname)
            set(handles.EDIT_fileOut,'String','',...
                'TooltipString','Choose a folder where the results will be saved.');            
            handles.AutoNewFolder = 1;
            set(handles.CB_resultsFolder,'Value',1);
        end
    end
    guidata(hObject, handles);
        
function CB_resultsFolder_Callback(hObject, eventdata, handles)
    switch get(hObject,'Value')
        case 0
            set(handles.PB_newFolder,'Enable','on');
            handles.AutoNewFolder = 0;
        case 1
            set(handles.PB_newFolder,'Enable','off');
            handles.AutoNewFolder = 1;
    end
    guidata(hObject, handles);
    
function handles = PB_newFolder_Callback(hObject, eventdata, handles)
% creates a new folder in the parentFolder of the data directory called
% '..\Results\<Date__Time>'
    %-get parentFolder of data directory:----------------------------------
    switch handles.modusShown
        case 1
            [filein,n,e] = fileparts(handles.pathes.image);  % get data directory
        case 2
            [filein,n,e] = fileparts(handles.pathes.file);
        case 3
            filein = handles.pathes.cdf;
    end
    if ~isdir(char(filein))
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits red
            'BackgroundColor',[1 108/255 108/255]);
        uiwait(errordlg('Please first select a file or folder!','No data directory found','modal'));
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits white
            'BackgroundColor',[1 1 1]);
        return
    end
    parentFolder = filein;
    %-get date+time--------------------------------------------------------
    c = fix(clock);
    date = sprintf('%u-%02u-%02u__%02u-%02u-%02u',c);
    %-check, weather data is allready from Results-folder
    [pF, name_pF, ext_pF] = fileparts(parentFolder);
    [pF2, name_pF2, ext_pF2] = fileparts(pF);   % name_pF2 would be a folder named 'Results', if data directory of image or file is an automatically created one
    if strcmp(name_pF,'Results')
        newFolder = [parentFolder filesep date];
    elseif strcmp(name_pF2,'Results')
        newFolder = [pF filesep date];
    else        
        newFolder = [parentFolder filesep 'Results' filesep date];
    end
    %-create new folder and set resultFolder to the newly created----------
    mkdir(newFolder);
    handles.pathes.results = newFolder;
    PB_fileOut_Callback(handles.PB_newFolder, eventdata, handles);
    guidata(hObject, handles);
    
    
% Plot Settings: Division of the Histogram
function PUM_plotDiv_Callback(hObject, eventdata, handles)
    handles.plotDiv = get(hObject,'Value');
    switch handles.plotDiv
        case 1
            set(handles.TEXT_edit_plot,'String','How long shall be the sections?');
            set(handles.EDIT_plot,'String','3');
            handles.plot = 3;
        case 2
            set(handles.TEXT_edit_plot,'String','How many sections?');
            set(handles.EDIT_plot,'String','10');
            handles.plot = 10;
    end    
    % refresh histogram
    handles.autoLimits = 1;
    if (handles.isStarted) && (handles.modus ~= 3)
        [handles] = plotHist(hObject, eventdata, handles);
    end
    guidata(hObject, handles);
    
% Plot Settings: Amount of X in Histogram
function EDIT_plot_Callback(hObject, eventdata, handles)
    val = str2num(get(hObject,'String'));
    if val>0  % only positive non-zero values possible
        handles.plot = val;
        % Histogramm nachträglich ändern
        if (handles.isStarted) && (handles.modus ~= 3)
            handles.autoLimits = 1;
            [handles] = plotHist(hObject, eventdata, handles);
        end
    else
        set(hObject,'String',num2str(handles.plot));
    end;
    guidata(hObject, handles);

% Plot Settings: Show-Button
function PB_showHist_Callback(hObject, eventdata, handles)
    [handles] = plotHist(hObject, eventdata, handles);
    guidata(hObject, handles);
    
    
    
%% Main Code
% this is the main functionality of this program. Diveded in three
% Callbacks - one for each main function (image/file/cdf)
%
%% Start: Image
function PB_startImage_Callback(hObject, eventdata, handles)
    % Security-Check, if data is displayed
    if handles.isStarted
        a = questdlg('This will overrrite current data. So you wish to continue?','line cut','Yes','No','Yes'); % Sichterheitsabfrage
        if strcmp(a,'Yes')
            cla(handles.AXES_image) % clears all children of AXES_image
            cla(handles.AXES_plot)
            set(handles.tools_save,'Enable','off'); % disable save
        else
            return    % cancels function
        end
    end
    % check, if file is selected
    [pi, ni, ei] = fileparts(handles.pathes.image);
    if ~isdir(pi)
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits red
            'BackgroundColor',[1 108/255 108/255]);
        uiwait(errordlg('Please first select a file!','No data directory found','modal'));
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits white
            'BackgroundColor',[1 1 1]);
        return
    end
    % run Scale-Fct; in case the user did a file-Analyse with e.g. 'µm' as
    % scale and then run image analysis with default values (nm), the scale
    % stays 'µm' => run scale-fct to set the default value to scale/unit
    handles = PUM_length_Callback(handles.PUM_length, eventdata, handles);
    % ---------------------------------------------------------------------
    handles.isStarted = 1;
    handles.modus = 1;
    hold off
    % set appearance of GUI for "Image"
    handles.visible.hints = 1;
    handles.visible.image = 1;
    handles.visible.plot = 0;
	handles.visible.imageSmall=0;
    handles.visible.plotSmall=1;
    handles.visible.cdfList=0;
    handles.visible.fit=0;
    handles.visible.cdfDetails=0;
    handles.visible.plotSettings=0;  
    setVisibilities(hObject, eventdata, handles);
    figure_ResizeFcn(hObject, eventdata, handles);
    %-Update results folder, if this option is selected--------------------
    if handles.AutoNewFolder
        handles = PB_newFolder_Callback(hObject, eventdata, handles);
    end
    %----------------------------------------------------------------------
    filename = handles.pathes.image;    
    axes(handles.AXES_image);
    zoomLimits = get(gca,{'xlim','ylim'});  % Get axes limits with zoom    
    col = [.6 .6 .6];   % color of text in the panel "Hints"
    %-Korrekturfaktor für Korngrenzendurchmesser [Vgl.: Werkstoffkunde III,
    % (verwendent in Zeile 1061 ff.)              Prof. Zum Gahr, Seite 31]
    L_zu_D = handles.LzuD;
    %-------------
    % load image
    I=imread(filename);
    I_info = imfinfo(filename);
    imshow(I); %,'InitialMagnification','fit');   
    zoom reset  % resets to 100% zoom
    set(gca,{'xlim','ylim'},zoomLimits) % restores zoom before starting
    %% Skalierung des Massbalkens
    set(handles.TEXT_hints1,'ForegroundColor',[0 0 0]);  % Hinweisfarbe durchschalten in Reihenfolge
    set(handles.TEXT_hints4,'ForegroundColor',col);
    conditionBar = true;
    hold on
    while conditionBar  % Check wheater scalebar is marked correctly
        clear x
        clear y
        [x,y] = ginput(2);                              % Massbalken anklicken
        hScaleBar = plot(x,y,'b','LineWidth',2);
        if handles.scaleBarMarker
            a = questdlg('Accept line?','line cut','Yes','No','Yes'); % Sichterheitsabfrage                
            if strcmp(a,'Yes')
                conditionBar = false; % false: while-Schleife wird abgebrochen//true: läuft nochmal durch
            else
                delete(hScaleBar)
            end
        else
            conditionBar = false;   % Acception question isn't desired
        end
    end
    laenge = abs(round(sqrt((x(2)-x(1))^2 + (y(2)-y(1))^2)));
    % Berechnung Balkenlaenge
    fak = handles.scale;
    balkenlaenge = handles.length*fak;  %in nm  
    laengepropixel = balkenlaenge/laenge; 
%             if handles.massbalken == 1  % extra Fenster schließen nach Maßbalkenskalierung
%                 delete(hb);
%             end       
    %% zu untersuchender Bereich
    zoom out % showes whole picture
    zoom off 
    set(handles.TEXT_hints1,'ForegroundColor',col);
    % if crop option is active
	if handles.crop
    	set(handles.TEXT_hints2,'ForegroundColor',[0 0 0]);
        h = imrect;
        wait(h);
        pos = getPosition(h);
        xmin=pos(1);
        ymin=pos(2);
        xmax=pos(3);
        ymax=pos(4);
        I2 = imcrop(I,[xmin ymin xmax ymax]);   % ?? I2 = imcrop(I,pos);
%         if handles.korngrenzen == 1  % image in neuem Fenster anzeigen zur Korngrenzenmarkierung
%         	hb = figure('Name','Mark the grain boundaries:',...   
%             	'Units','pixels',...
%                 'MenuBar','none',...
%                 'ToolBar','none'); 
%         end
        hold off
        imshow(I2); %,'InitialMagnification','fit')
        imwrite(I2,[handles.pathes.results filesep 'gecropt.jpg']);
        w=imfinfo([handles.pathes.results filesep 'gecropt.jpg']);
        width = getfield(w,'Width');    % ?? w.Width
        height= getfield(w,'Height');
    else
%         if handles.korngrenzen == 1  % image in neuem Fenster anzeigen zur Korngrenzenmarkierung
%         	hb = figure('Name','Mark the grain boundaries:',...   
%             	'Units','pixels',...
%                 'MenuBar','none',...
%                 'ToolBar','none'); 
%             imshow(I,'InitialMagnification','fit')
%         end    
        w=imfinfo(filename);
        width = getfield(w,'Width');
        height= getfield(w,'Height');
	end % end beschneiden j/n
   
    hold on
	%% n linien in rot zeichnen
    n=handles.lines;
    nn=height/n;
	for k=1:n
        h=1+((k-1)*nn);
        xline = [0 width+1];
        yline = [h+nn/2 h+nn/2];
        ylinie(k)=(h+nn/2);
        plot(xline,yline,'Color','r','LineStyle','-');
	end
    %% Anklicken in n zeilen und abspeichern der sehnenlaengen        
            set(handles.TEXT_hints3,'ForegroundColor',[0 0 0]);
            set(handles.TEXT_hints2,'ForegroundColor',[0 0 0]);
            set(handles.TEXT_hints2,'ForegroundColor',col);
    
            lengthall=0;
            length=0;
    
            % anklicken und angeklickte linien blau färben
            for i = 1:n            
                condition = true;   % speichert, ob die Zeile in Ordnung ist => solange true, müssen die Korngrenzen erneut angeklickt werden
                while condition
                    switch handles.microstructure
                        case 1  % 1-phasig // normale Analyse
                            [x,y,taste] = ginput(100);
                            length = size(x,1);
                            %-Testet, ob abgebrochen werden soll-----------------------
                            for c = 1:length         
                                if taste(c)==27         % 27 entspricht der Esc-Taste (ASCII)
                                    a = questdlg('Really cancel? Progress gets lost!','cancel editing','Yes','No','No'); % security check                
                                    if strcmp(a,'Yes')
                                        set(handles.TEXT_hints3,'ForegroundColor',col);
                                        % set appearance of GUI for "Image"
                                        handles.visible.hints = 0;
                                        handles.visible.image = 1;
                                        setVisibilities(hObject, eventdata, handles);
                                        figure_ResizeFcn(hObject, eventdata, handles);
                                        cla(handles.AXES_image);
                                        imshow(I);
                                        handles.isStarted = 0;
                                        if handles.crop  % && (get(handles.PUM_file,'Value') == 1) && (handles.isHist == 0)
                                            delete([handles.pathes.results filesep 'gecropt.jpg']);
                                        end
                                        disp('canceled')
                                        guidata(hObject, handles);
                                        return      % beendet die aktuelle function
                                    end
                                end
                            end
                            %-Ende Abbruchtest-----------------------------------------
                            x=sort(x);
                            %-Bildrand hinzufügen
                            if (handles.start - 1)
                                xx(1,1) = 1;
                                xx(2:length+1,1) = x;
                                clear x;
                                x = xx;
                                length = size(x,1);
                                clear xx;
                            end
                            if (handles.end - 1)
                                xx(1:length,1) = x;
                                xx(length+1,1) = I_info.Width;
                                clear x;
                                x = xx;
                                length = size(x,1);
                                clear xx;
                            end
                            %-Ende Bildrand
                            ydots = ones(length,1).*ylinie(i);                
                            hold on
                            dots = plot(x,ydots,'o'); % dots ist handle der Punkte einer Reihe                
                
                            if handles.korngrenzen
                                a = questdlg('Accept line?','line cut','Yes','No','Yes'); % Sichterheitsabfrage                
                                if strcmp(a,'Yes')
                                    condition = false; % false: while-Schleife wird abgebrochen//true: läuft nochmal durch
                                else
                                    delete(dots)
                                end
                            else
                                condition = false;  % While-Schleife wird immer abgebrochen, wenn Checkbox unchecked ist
                            end
                            
                        case 2  % 2-phasig // Matrix-Analyse
                            condition2 = true;
                            dx = 0;
                            c = 1;
                            hold on
                            while condition2
                                [x,y,taste] = ginput(2);
                                %-Testet, ob abgebrochen werden soll-------
                                if any(taste == 27)
                                    a = questdlg('Really cancel? Progress gets lost!','cancel editing','Yes','No','No'); % security check                
                                    if strcmp(a,'Yes')
                                        set(handles.TEXT_hints3,'ForegroundColor',col);
                                        % set appearance of GUI for "Image"
                                        handles.visible.hints = 0;
                                        handles.visible.image = 1;
                                        setVisibilities(hObject, eventdata, handles);
                                        figure_ResizeFcn(hObject, eventdata, handles);
                                        cla(handles.AXES_image);
                                        imshow(I);
                                        handles.isStarted = 0;
                                        if handles.crop  % && (get(handles.PUM_file,'Value') == 1) && (handles.isHist == 0)
                                            delete([handles.pathes.results filesep 'gecropt.jpg']);
                                        end
                                        disp('canceled')
                                        guidata(hObject, handles);
                                        return      % beendet die aktuelle function
                                    end
                                end
                                %-Ende Abbruchtest-------------------------
                                %-Strichlänge dx, wenn 2 Mal geklickt wurde
                                if (size(x,1) == 2)
                                    striche(c) = plot([x(1) x(2)],[ylinie(i) ylinie(i)],'-b');
                                    dx(c) = abs((x(2) - x(1)));
                                    c = c + 1;
                                else
                                    condition2 = false;
                                end
                            end
                            %-Sicherheitsabfrage am Ende jeder Zeile, wenn
                            % CheckBox aktiv ist
                            if handles.korngrenzen
                                a = questdlg('Accept line?','line cut','Yes','No','Yes'); % Sichterheitsabfrage                
                                if strcmp(a,'Yes')
                                    condition = false; % false: while-Schleife wird abgebrochen//true: läuft nochmal durch
                                else
                                    delete(striche)
                                end
                            else
                                condition = false;  % While-Schleife wird immer abgebrochen, wenn Checkbox unchecked ist
                            end                           
                    end
                end  
                
                switch handles.microstructure
                	case 1  % 1-phasig // normale Analyse
                        yline = [ylinie(i) ylinie(i)];
                        plot(xline,yline,'Color','b','LineStyle','-');
        
                        for s=1:length-1
                            sehnenlaenge(s+lengthall)=(x(s+1)-x(s))*laengepropixel/L_zu_D;
                        end
                        lengthall=(length-1)+lengthall;
                    case 2  % 2-phasig // Matrix-Analyse
                        for s=1:c-1
                            sehnenlaenge(s+lengthall)=dx(s)*laengepropixel/L_zu_D;
                        end
                        lengthall=(c-1)+lengthall;
                end
            end % end for n Linien
	handles.sehnenlaenge = sehnenlaenge;
%             if handles.korngrenzen == 1       % NICHT MEHR KORNGRENZEN
%             NENNEN!!! GIBTS SCHON
%                 delete(hb); % extra Fenster schließen nach Korngrenzenmarkierung
%             end  
    % save chordlength in results folder as:
    % "chordlength_<unit>_<originalFilename>.txt"
	[filepath, just_filename, ext] = fileparts(filename);
    dlmwrite([handles.pathes.results,filesep,'chordlength_',char(handles.unit),'_',char(just_filename),'.txt'],sehnenlaenge');
    % reset colors of hints
    set(handles.TEXT_hints4,'ForegroundColor',[0 0 0]);
    set(handles.TEXT_hints2,'ForegroundColor',col);
    set(handles.TEXT_hints3,'ForegroundColor',col);  
    if handles.crop  % && (get(handles.PUM_file,'Value') == 1) && (handles.isHist == 0)
    	delete([handles.pathes.results filesep 'gecropt.jpg']);
    end 
    % set appearance of GUI for "Image => plot"
    handles.visible.hints = 1;
    handles.visible.image = 1;
    handles.visible.plot = 1;
    cla(handles.AXES_plot);
	handles.visible.imageSmall=1;
    handles.visible.plotSmall=0;
    handles.visible.plotSettings=1; 
    handles.autoLimits = 1;  
    setVisibilities(hObject, eventdata, handles);
    figure_ResizeFcn(hObject, eventdata, handles);
    set(handles.AXES_image,'XTick',[],'YTick',[]);
    [handles] = plotHist(hObject, eventdata, handles);  % Histogramm plotten
         
    guidata(hObject, handles);
    
    
%% Start: File
function PB_startFile_Callback(hObject, eventdata, handles)
    % Security-Check, if data is displayed
    if handles.isStarted
        a = questdlg('This will overrrite current data. So you wish to continue?','line cut','Yes','No','Yes'); % Sichterheitsabfrage
        if strcmp(a,'Yes')
            cla(handles.AXES_plot) % clears all children of AXES_plot
            set(handles.tools_save,'Enable','off'); % disable save
        else
            return    % cancels function
        end
    end
    % check, if file is selected
    [pi, ni, ei] = fileparts(handles.pathes.file);
    if ~isdir(pi)
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits red
            'BackgroundColor',[1 108/255 108/255]);
        uiwait(errordlg('Please first select a file!','No data directory found','modal'));
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits white
            'BackgroundColor',[1 1 1]);
        return
    end
    % run Scale-Fct; in case the user did a cdf with e.g. 'µm' as
    % scale and then run image analysis with default values (nm), the scale
    % stays 'µm' => run scale-fct to set the default value to scale/unit
    handles = PUM_scaleFile_Callback(handles.PUM_scaleFile, eventdata, handles);
    % ---------------------------------------------------------------------
    handles.isStarted = 1;
    handles.modus = 2;
    %-Update results folder, if this option is selected--------------------
    if handles.AutoNewFolder
        handles = PB_newFolder_Callback(hObject, eventdata, handles);
    end
    %----------------------------------------------------------------------
    filedata = importdata(handles.pathes.file);
    if isfield(filedata,'data')
        sehnenlaenge = filedata.data;	% comes from files with header
    else
        sehnenlaenge = filedata;        % comes from files without header
    end
    handles.sehnenlaenge = sehnenlaenge;
    
    % set appearance of GUI for "File"
    handles.visible.hints = 0;
    handles.visible.image = 0;
    handles.visible.plot = 1;
	handles.visible.imageSmall=1;
    handles.visible.plotSmall=0;
    handles.visible.cdfList=0;
    handles.visible.cdfDetails=0;
    handles.visible.plotSettings=1;   
    handles.autoLimits = 1;
    setVisibilities(hObject, eventdata, handles);
    figure_ResizeFcn(hObject, eventdata, handles);
    
    [handles] = plotHist(hObject, eventdata, handles);  % Histogramm plotten
    
    guidata(hObject, handles);

    
%% Start: CDF
function PB_startCdf_Callback(hObject, eventdata, handles)
    % Security-Check, if data is displayed
    if (handles.isStarted) && (~handles.cdfHold)
        a = questdlg('This will overrrite current data. So you wish to continue?','line cut','Yes','No','Yes'); % Sichterheitsabfrage
        if strcmp(a,'Yes')
            cla(handles.AXES_plot) % clears all children of AXES_plot
            set(handles.tools_save,'Enable','off'); % disable save
        else
            return    % cancels function
        end
    end
    % check, if folder is selected
    if ~isdir(handles.pathes.cdf)
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits red
            'BackgroundColor',[1 108/255 108/255]);
        uiwait(errordlg('Please first select a file!','No data directory found','modal'));
        set([handles.EDIT_fileFile,handles.EDIT_fileImage,handles.EDIT_folderCdf],...    % make folder-Edits white
            'BackgroundColor',[1 1 1]);
        return
    end
    % run Scale-Fct; in case the user did a file-analysis with e.g. 'µm' as
    % scale and then run image analysis with default values (nm), the scale
    % stays 'µm' => run scale-fct to set the default value to scale/unit
    handles = PUM_scaleCdf_Callback(handles.PUM_scaleCdf, eventdata, handles);
    % ---------------------------------------------------------------------
    handles.isStarted = 1;
    handles.modus = 3;
    %-Update results folder, if this option is selected--------------------
    if handles.AutoNewFolder
        handles = PB_newFolder_Callback(hObject, eventdata, handles);
    end
    %----------------------------------------------------------------------
    % set appearance of GUI for "CDF"
    handles.visible.hints = 0;
    handles.visible.image = 0;
    handles.visible.plot = 0;
    if ~handles.cdfHold
        cla(handles.AXES_plot);
    end
	handles.visible.imageSmall=1;
    handles.visible.plotSmall=1;
    handles.visible.cdfList=1;
    handles.visible.fit=0;
    handles.visible.cdfDetails=0;
    handles.visible.plotSettings=0; 
    setVisibilities(hObject, eventdata, handles);
    figure_ResizeFcn(hObject, eventdata, handles);
    % ---------------------------------------------------------------------
	filenames = '';
    list = get(handles.LIST_cdf,'String');
    list_val = get(handles.LIST_cdf,'Value');
    y = size(list_val,2);
    for i=1:y
        if i==1
        	filenames = char(list(list_val(i),:));
        else
        	filenames = char(filenames,list(list_val(i),:));
        end
    end
    handles.filenamesCdf = filenames;
    if ~handles.cdfHold
    	handles.countCdf = 0;
    end
    handles.countCdf = handles.countCdf + 1;
    
    % set appearance of GUI for "CDF => plot"handles.visible.hints = 0;
    handles.visible.plot = 1;
    handles.visible.plotSmall=0;
    handles.visible.cdfDetails=1;
    handles.visible.plotSettings=1; 
    handles.autoLimits = 1;
    setVisibilities(hObject, eventdata, handles);
    figure_ResizeFcn(hObject, eventdata, handles);

	[handles] = plotHist(hObject, eventdata, handles);  % Histogramm plotten
    
    guidata(hObject, handles);

    
%% Plot: Histogram/CDF
% this function controlls the results plot and runs after every change of
% plot setting (e.g. fit y/n) except changes of axes limits
function [handles] = plotHist(hObject, eventdata, handles)
% Schriftgröße der Labels
%     sg = 'fontsize{13}';     % Edit the Number: Fontsize of Labels in pixel
    % enable save
    set(handles.tools_save,'Enable','on');
    % Plot-Farben festlegen
    plotcolor = ['b','m','k','r','g','y','c'];
    % Skalierungsfaktor auslesen
    fak = handles.scale;
% plotten in Histogramm
    hold off
    if ~handles.autoLimits      % handles.autoLimits
        xl = get(handles.AXES_plot,'XLim');
        yl = get(handles.AXES_plot,'YLim');
    end          
    switch hObject
        case handles.PB_showHist        % in neuem figure anzeigen
            hHist = figure;
        otherwise                       % in der GUI anzeigen
            axes(handles.AXES_plot);
    end
    switch handles.modus
        case {1,2}
            sehnenlaenge = handles.sehnenlaenge/fak;    
            maxi=max(sehnenlaenge);
            mini=min(sehnenlaenge);
            switch handles.plotDiv
                case 1
                    s = handles.plot;
                    if s > 2/3*(maxi-mini)
                        s = 2/3*(maxi-mini);
                        handles.plot = s;
                        set(handles.EDIT_plot,'String',num2str(s));
                    end
                    % fitting-curve needs at least 3 datapoints
                    if handles.showFit && s > 2/3*(maxi-mini)*1/3
                        handles.showFit = 0;
                        set(handles.CM_plot_showFit,'Checked','off')
                        hCurrentAxes = gca;
                        errordlg('You need at least 3 datapoints to display the fitting curve!','Not able to display fit','modal');
                        axes(hCurrentAxes);
                    end
                case 2
                    t = handles.plot;
                    s=(maxi-mini)/(t);  % former: s=(maxi-mini)/(t-1)
            end
            x=mini+(s/2):s:(maxi);
%             handles.x_sehne = x;    % Wo?
            hist(sehnenlaenge,x);
            xlabel(['length [',char(handles.unit),']']);
            ylabel('frequency [ ]');
            switch handles.modus
                case 1
                    [p,n,e] = fileparts(handles.pathes.image);
                case 2
                    [p,n,e] = fileparts(handles.pathes.file);
            end
            title(['histogram chordlength ' char(n)]);
            if ~handles.autoLimits
                xlim(xl);
                ylim(yl);
            end
            
            if handles.showFit %strcmp(get(handles.CM_plot_anzeigen,'Checked'),'on')
                %% lognormal distribution fitting (by Jogge)
                splx = get(get(gca,'Children'), 'XData');
                sply = get(get(gca,'Children'), 'YData');

                logn = fittype(['A./(sqrt(2.*pi).*x.*log(a_sig)).*exp(-(log(x)-log(a_mu)).^2./(2.*(log(a_sig)).^2))']);
                xl = get(gca,'XLim');
                startpoint = [1 20 1.7]; lower = [0 5 0]; upper = [200 200 10]; 
       
                opts = fitoptions('Method','NonlinearLeastSquares',...
                    'Robust', 'off',...
                    'Algorithm', 'Trust-Region',...
                    'StartPoint', startpoint,...
                    'Lower',      lower,...
                    'Upper',      upper,...
                    'MaxFunEvals',2000,...
                    'TolX', 10e-10,...
                    'TolFun', 10e-10);   
    
                drange = xl(1):0.5:xl(2)';
                [lognorm gof] = fit(((splx(2,:)+splx(3,:))./2)', (sply(2,:)./max(sply(2,:)))', logn, opts);
                hold on;
                if hObject==handles.PB_showHist
                    plot(drange, max(sply(2,:)).*feval(lognorm,drange), '-', 'LineWidth', 2, 'Color','r');
                else
                    plot(drange, max(sply(2,:)).*feval(lognorm,drange), '-', 'LineWidth', 2, 'Color','r','UIContextMenu',handles.CM_plot); 
                end
                hold off;
                lognorm % Fit-Parameter in der Konsole anzeigen
    
                lognorm_names  = coeffnames(lognorm);
                lognorm_values = coeffvalues(lognorm);
    
                handles = PB_showPlotDetails_Callback(handles.PB_showPlotDetails, eventdata, handles);
                set(handles.TEXT_fit1,'String',[char(lognorm_names(1)),': ',num2str(lognorm_values(1))]);
                set(handles.TEXT_fit2,'String',[char(lognorm_names(2)),': ',num2str(lognorm_values(2))]);
                set(handles.TEXT_fit3,'String',[char(lognorm_names(3)),': ',num2str(lognorm_values(3))]);
            else
                handles = PB_hideFit_Callback(handles.PB_hideFit, eventdata, handles);
            end
        case 3  %-Summenverteilung-----------------------------------------
            path = [handles.pathes.cdf filesep];
            filenames = handles.filenamesCdf;
            x = size(filenames,1);
            for i=1:x
                sehnenlaenge=importdata([path char(filenames(i,:))])/fak;
                if size(sehnenlaenge,1) < size(sehnenlaenge,2)
                    sehnenlaenge = sehnenlaenge';
                end
                if i==1
                    F = sehnenlaenge;
                else
                    F = [F; sehnenlaenge];
                end
            end
            if handles.cdfHold
                hold on
            else
                hold off
            end
            i = handles.countCdf;
            
            if hObject == handles.PB_showHist   % alle anzeigen in neuem fenster
                for n = 1:i
                    cp = cdfplot(handles.cdf_data{n});
                    set(cp,'Color',plotcolor(n));                    
                end
            else
                handles.cdf_data{i} = F;
                [cp,stats] = cdfplot(F);
                set(cp,'Color',plotcolor(i));
                data = get(handles.TABLE_cdf,'Data');
                if i==1 
                    data = cell(5,1); % Tabelle leeren, wenn hold off
                end
                data{1,i} = stats.min;
                data{2,i} = stats.max;
                data{3,i} = stats.mean;
                data{4,i} = stats.median;
                data{5,i} = stats.std;
                set(handles.TABLE_cdf,'Data',data);
            end
            xlabel(['length [',char(handles.unit),']']);
            ylabel('frequenzy []');
            if ~handles.autoLimits
                xlim(xl);
                ylim(yl);
            end
            leg = handles.legendCdf;
            if hObject ~= handles.PB_showHist
                leg{i} = ['CDF',num2str(i)];
                set(handles.EDIT_cdfName,'String',char(leg{i}));
            end
            hleg = legend(leg,'Location','SouthEast');
            set(hleg,'FontSize',8)
            set(handles.CB_cdfHold,'Visible','on');
            handles.legendCdf = leg;
    end  
    
    if handles.autoLimits
        xl = get(gca,'XLim'); yl = get(gca,'YLim');
        set(handles.EDIT_XLim_min,'String',num2str(xl(1)));
        set(handles.EDIT_XLim_max,'String',num2str(xl(2)));
        set(handles.EDIT_YLim_min,'String',num2str(yl(1)));
        set(handles.EDIT_YLim_max,'String',num2str(yl(2)));
        handles.autoLimits = 0;
    end
    
    % Histogramm speichern  
%     if hObject == handles.PB_showHist
%         cd(handles.fo) 
%         switch get(handles.PUM_file,'Value')
%             case {1,2}
%                 saveas(hHist,[handles.fn,'Histogramm.fig']);
%                 saveas(hHist,[handles.fn,'Histogramm.emf']);
%             case 3
%                 saveas(hHist,[handles.fn,'Summenverteilung.fig']);
%                 saveas(hHist,[handles.fn,'Summenverteilung.emf']);
%         end
%     end

% Plot: Limits
function EDIT_XLim_max_Callback(hObject, eventdata, handles)
    set(handles.AXES_plot,'XLim',[str2num(get(handles.EDIT_XLim_min,'String')) str2num(get(handles.EDIT_XLim_max,'String'))]);
    guidata(hObject, handles);

function EDIT_XLim_min_Callback(hObject, eventdata, handles)
    set(handles.AXES_plot,'XLim',[str2num(get(handles.EDIT_XLim_min,'String')) str2num(get(handles.EDIT_XLim_max,'String'))]);
    guidata(hObject, handles);
    
function EDIT_YLim_max_Callback(hObject, eventdata, handles)
    set(handles.AXES_plot,'YLim',[str2num(get(handles.EDIT_YLim_min,'String')) str2num(get(handles.EDIT_YLim_max,'String'))]);
    guidata(hObject, handles);    
    
function EDIT_YLim_min_Callback(hObject, eventdata, handles)    
    set(handles.AXES_plot,'YLim',[str2num(get(handles.EDIT_YLim_min,'String')) str2num(get(handles.EDIT_YLim_max,'String'))]);
    guidata(hObject, handles);
    
    
    
%% Menu
% File --------------------------------------------------------------------
function menu_file_new_Callback(hObject, eventdata, handles)
    a = questdlg({'Unsaved data will be lost!';'';'Are you sure?'},'New','Yes','No','Yes'); % Sichterheitsabfrage
    if strcmp(a,'Yes')
        delete(handles.figure);  % Fenster schließen
        GUI_linecut   % GUI neu starten
    end

function menu_file_close_Callback(hObject, eventdata, handles)
    figure_CloseRequestFcn(hObject, eventdata, handles);
    
% Image -------------------------------------------------------------------
function menu_image_rotate_Callback(hObject, eventdata, handles)
% pops up a new window, where the Input-Picture can be turned. Writes the
% turned picture into data directory and sets current file to turned-
% picture-file
    if (handles.visible.image ~= 1) && (~isempty(handles.pathes.image))
        errordlg('Image rotation is only possible in "Image"-Mode with selected image file!','Linecut');
        return
    end
    filename = handles.pathes.image;
    abbruch = GUI_bildDrehen(filename);
    if abbruch == 0
        [parentFolder, name, ext] = fileparts(filename);
        newImage = [parentFolder filesep name '_turned' ext];
        handles.pathes.image = newImage;
        PB_fileImage_Callback(hObject, eventdata, handles);
    end
    guidata(hObject, handles);

    
% Settings ----------------------------------------------------------------   
function menu_settings_config_show_Callback(hObject, eventdata, handles)
    global config_dir
    open([config_dir filesep 'config.txt'])
    
function menu_settings_config_default_Callback(hObject, eventdata, handles, fileOverride, fileNew)
    % ersetzt config-Datei durch eine Standart-Config im gleichen Ordner
    global config_dir
    a = questdlg({'Do you want to reset config-file to default?';'';'Are you sure?'},'New','Yes','No','Yes'); % Sichterheitsabfrage
    if strcmp(a,'Yes')
        disp(copyfile([config_dir filesep 'configDefault.txt'],[config_dir filesep 'config.txt'],'f'))
    end
    
    
function menu_settings_config_set_Callback(hObject, eventdata, handles)
    % writes current settings to config-file
    msg = saveConfig('config.txt', eventdata, handles);  
    if isempty(msg)
        msgbox('Current settings saved!','Config')
    else
        errordlg(msg,'Saving failed');
    end

        
% Help --------------------------------------------------------------------
function menu_help_about_Callback(hObject, eventdata, handles)
    text = sprintf('line cut\nGUI_linecut.m\n\nVersion 2.0          06.02.2012\n');
    msgbox(text,'About...');
    

%% Toolbar tools
% New
function tools_new_ClickedCallback(hObject, eventdata, handles)
    menu_file_new_Callback(hObject, eventdata, handles)
    
% saves AXES_plot at results folder
function tools_save_ClickedCallback(hObject, eventdata, handles)
% BUG!! savesas SAVES WHOLE FIGURE AND NOT JUST THE AXES WITH PLOT AS IT SHOULD!!
% hgsave doesn't allow changes after saving
    %-Update results folder, if this option is selected--------------------
    if handles.AutoNewFolder
        handles = PB_newFolder_Callback(hObject, eventdata, handles);
    end
    %----------------------------------------------------------------------
    if ~isdir(char(handles.pathes.results))
        errordlg('Please choose/create results folder!','No results folder found');
        return
    end
    switch handles.modus
        case 1
            [p,n,e] = fileparts(handles.pathes.image);
            filename = [handles.pathes.results n];
        case 2
            [p,n,e] = fileparts(handles.pathes.file);
            filename = [handles.pathes.results n];
        case 3 
            filename = handles.pathes.results;
    end
	switch handles.modus
    	case {1,2}
            % buggy... other fct needed!
            % e.g.: hist_plot in new figure => saveas => delete new figure
        	hgsave(handles.AXES_plot,[filename 'Histogramm.fig']);
            hgsave(handles.AXES_plot,[filename 'Histogramm.emf']);
        case 3
        	saveas(handles.AXES_plot,[filename 'Summenverteilung.fig']);
            saveas(handles.AXES_plot,[filename 'Summenverteilung.emf']);
	end

    
%% Context Menu
% Plot: show fit in Histogram
function CM_plot_showFit_Callback(hObject, eventdata, handles)
    switch get(hObject,'Checked')
        case 'on'
            set(hObject,'Checked','off')
            handles.showFit = 0;
        case 'off'
            set(hObject,'Checked','on')
            handles.showFit = 1;
    end
    handles = plotHist(hObject, eventdata, handles);
    guidata(hObject, handles);
    
% Pathes: delete     
% deletes path from edit and handles structure, e.g. to save settings
% without pathes
function CM_pathesResults_delete_Callback(hObject, eventdata, handles)
    PB_fileOut_Callback(handles.CM_pathesResults, eventdata, handles)
    handles.pathes.results = '';
    guidata(hObject,handles);

function CM_pathesCdf_delete_Callback(hObject, eventdata, handles)
    PB_folderCdf_Callback(handles.CM_pathesCdf, eventdata, handles)
    handles.pathes.cdf = '';
    guidata(hObject,handles);

function CM_pathesFile_delete_Callback(hObject, eventdata, handles)
    PB_fileFile_Callback(handles.CM_pathesFile, eventdata, handles)
    handles.pathes.file = '';
    guidata(hObject,handles);

function CM_pathesImage_delete_Callback(hObject, eventdata, handles)
    PB_fileImage_Callback(handles.CM_pathesImage, eventdata, handles)
    handles.pathes.image = '';
    % hide image  
    handles.visible.hints = 0;
    handles.visible.image = 0; 
    setVisibilities(hObject, eventdata, handles);
    RESIZE_axes_image(hObject, eventdata, handles);
    RESIZE_panel_plot(hObject, eventdata, handles);
    guidata(hObject,handles);
        
    
%% Unused Callbacks & CreateFcns
function EDIT_YLim_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_YLim_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_XLim_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_XLim_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function menu_file_Callback(hObject, eventdata, handles)

function EDIT_cdfName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PB_fittingsCurve_Callback(hObject, eventdata, handles)

function EDIT_fileout_Callback(hObject, eventdata, handles)

function EDIT_fileout_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PB_fileout_Callback(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_fileOut_Callback(hObject, eventdata, handles)

function EDIT_fileOut_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_fileImage_Callback(hObject, eventdata, handles)

function EDIT_fileImage_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PUM_length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_lines_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PUM_microstructure_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_LzuD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PUM_start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PUM_end_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PUM_plotDiv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_plot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_folderCdf_Callback(hObject, eventdata, handles)

function EDIT_folderCdf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_amountCdf_Callback(hObject, eventdata, handles)

function EDIT_amountCdf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDIT_fileFile_Callback(hObject, eventdata, handles)

function EDIT_fileFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PUM_scaleFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PUM_scaleCdf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LIST_cdf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CM_plot_Callback(hObject, eventdata, handles)

function menu_image_Callback(hObject, eventdata, handles)

function menu_help_Callback(hObject, eventdata, handles)

function menu_settings_Callback(hObject, eventdata, handles)

function menu_settings_config_Callback(hObject, eventdata, handles)

function CM_pathes_toConfig_Callback(hObject, eventdata, handles)

function CM_pathes_Callback(hObject, eventdata, handles)
    
function CM_pathesImage_Callback(hObject, eventdata, handles)

function CM_pathesFile_Callback(hObject, eventdata, handles)

function CM_pathesCdf_Callback(hObject, eventdata, handles)

function CM_pathesResults_Callback(hObject, eventdata, handles)
