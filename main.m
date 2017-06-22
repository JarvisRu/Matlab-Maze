function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 29-May-2017 20:00:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% ------------------------------------------------------------------------------
% file open and get length of bound
global col_length;
global row_length;
mazeFile = fopen('\maze\maze.txt');
col=fgetl(mazeFile);
col_length=length(col);
fclose(mazeFile);

mazeFile = fopen('\maze\maze.txt');
array = fscanf(mazeFile,'%s');
all_length = length(array);
row_length = all_length/col_length;
fclose(mazeFile);

% create a array to store map
global NewArr;
NewArr = reshape(array, col_length, [])' - '0';

% ---------------depth first search find all-----------------------------------------
% find door x, y
global doorX;
global doorY;
global noDoor;
[doorX doorY]=find(NewArr==2);
if isempty(doorX)
    noDoor = 1;
else
    noDoor = 0;
end

% depth first search 
global ansArr2;
global doorRoute;
global route_num2;
global route_length2;
ansArr2 = zeros(row_length,col_length,1);
doorRoute = zeros(1,1);
[ansArr2 sol doorRoute] = DFS_Maze2(NewArr, ansArr2, 1, doorX, doorY, doorRoute);
route_num2 = sol
ansArr2 = zeros(row_length,col_length,sol);
doorRoute = zeros(1,sol);
[ansArr2 sol doorRoute] = DFS_Maze2(NewArr, ansArr2, 2, doorX, doorY, doorRoute);

% find route length
route_length2 = zeros(1,route_num2);

for i=1:route_num2
    r = find (ansArr2(:,:,i) == 5 );
    d = find(doorRoute == i);
    if isempty(d)
        route_length2(i) = length(r) + 1;
    else
        route_length2(i) = length(r) + 2;
    end
end
%--------------------through door-------------------------------------------
global ansArr;
global route_length;
global Door_count;
ansArr = zeros(row_length,col_length);
route_length = zeros(1,Door_count-1);
k = 1;
for i=1:route_num2
    d = find(doorRoute == i);
    if isempty(d)
    else
        ansArr(: , : ,k) = ansArr2( :, :, i);
        route_length(k) = route_length2(i);
        k = k+1;
    end
end
ansArr
route_length

% ------------------------set status---------------------------------------
global nowMap;
nowMap = 0;
global throughDoor;
throughDoor = 0;
global viewShortest;
viewShortest = 0;
% ------------------------for map---------------------------------------

% load map img
global ground;
global wall;
global door;
global start;
global startRole;
global win;
global grass;
ground = imread('\image\ground.png');
wall = imread('\image\rock.png');
door = imread('\image\door.png');
start = imread('\image\start.png');
startRole = imread('\image\startRole.png');
win = imread('\image\winFlag.png');
grass = imread('\image\grass.png');
% load role img
global roleRight;
global roleLeft;
global roleUp;
global roleDown;
global roleIndoor;
global roleWin;
roleRight = imread('\image\right.png');
roleLeft = imread('\image\left.png');
roleUp = imread('\image\up.png');
roleDown = imread('\image\down.png');
roleIndoor = imread('\image\inDoor.png');
roleWin = imread('\image\getFlag.png');


% set img size
global pixelH;
global pixelW;
pixelH = ceil(220/row_length);
pixelW = ceil(350/col_length);
ground = imresize(ground,[pixelH,pixelW]);
wall = imresize(wall,[pixelH,pixelW]);
door = imresize(door,[pixelH,pixelW]);
start = imresize(start,[pixelH,pixelW]);
grass = imresize(grass,[pixelH,pixelW]);
startRole = imresize(startRole,[pixelH,pixelW]);
win = imresize(win,[pixelH,pixelW]);
roleRight = imresize(roleRight,[pixelH,pixelW]);
roleLeft = imresize(roleLeft,[pixelH,pixelW]);
roleUp = imresize(roleUp,[pixelH,pixelW]);
roleDown = imresize(roleDown,[pixelH,pixelW]);
roleIndoor = imresize(roleIndoor,[pixelH,pixelW]);
roleWin = imresize(roleWin,[pixelH,pixelW]);


% create map
global map;
map = zeros(220,350,3,'uint8');
global startX;
global startY;

% print map
for i=1:row_length
    for j=1:col_length
        switch NewArr(i,j)
            case 0
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
            case 1
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
            case 2
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;   
            case 9
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
                startX = j;
                startY = i;
            case 8
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
        end
    end
end
axes(handles.map);
imshow(map); 

% ------------------------for role control------------------------------------
global stepNow;
global roleX;
global roleY;
roleX=startX
roleY=startY
stepNow=0;
set(handles.stepNum,'string','0');

% ------------------------print data------------------------------------
global commonString;
global initialString;
global noPath;
% has route or not
if route_num2 ~=0
    commonString = num2str(route_num2);
    commonString = strcat('/',commonString);
    initialString = strcat('0',commonString);
    noPath = 0;
else
    initialString = '0';
    noPath = 1;
    set(handles.status,'string','No path !!');
end
set(handles.routeNum,'string',initialString);

set(handles.lengthNum,'string','0');


fclose('all');



% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in buttonRight.
function buttonRight_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NewArr;
global map;
global roleX;
global roleY;
global doorX;
global doorY;
global col_length;
global pixelH;
global pixelW;
global ground;
global door;
global start;
global win;
global roleRight;
global roleIndoor;
global roleWin;
global stepNow;
global noDoor;
% save last x,y
lastX = roleX;
lastY = roleY;

% set move
if roleX == col_length
    set(handles.status,'string','Its bound, you can not move ');
else
    if noDoor == 0
        % into  door1
        if roleX+1 == doorY(1) && roleY == doorX(1)
            roleX = doorY(2);
            roleY = doorX(2);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % into  door2
        elseif roleX+1 == doorY(2) && roleY == doorX(2)
            roleX = doorY(1);
            roleY = doorX(1);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % not door and not wall
        elseif NewArr(roleY,roleX+1) ~= 0
            roleX = roleX + 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleRight;
            end

            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving right');
            end
        elseif NewArr(roleY,roleX+1) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    else
        if NewArr(roleY,roleX+1) ~= 0
            roleX = roleX + 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleRight;
            end

            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving right');
            end
        elseif NewArr(roleY,roleX+1) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    end
    % draw the map
    axes(handles.map);
    imshow(map);
    
    % count step
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
    
end



% --- Executes on button press in buttonLeft.
function buttonLeft_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NewArr;
global map;
global roleX;
global roleY;
global doorX;
global doorY;
global pixelH;
global pixelW;
global ground;
global door;
global start;
global win;
global roleLeft;
global roleIndoor;
global roleWin;
global stepNow;
global noDoor;
% save last x,y
lastX = roleX;
lastY = roleY;

% set move
if roleX == 1
    set(handles.status,'string','Its bound, you can not move ');
else
    if noDoor == 0
        % into  door1
        if roleX-1 == doorY(1) && roleY == doorX(1)
            roleX = doorY(2);
            roleY = doorX(2);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % into  door2
        elseif roleX-1 == doorY(2) && roleY == doorX(2)
            roleX = doorY(1);
            roleY = doorX(1);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % not door and not wall
        elseif NewArr(roleY,roleX-1) ~= 0
            roleX = roleX - 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleLeft;
            end
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving left');
            end
        elseif NewArr(roleY,roleX-1) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    else
        if NewArr(roleY,roleX-1) ~= 0
            roleX = roleX - 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleLeft;
            end
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving left');
            end
        elseif NewArr(roleY,roleX-1) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    end
    % draw the map
    axes(handles.map);
    imshow(map); 
    
    % count step
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
end


% --- Executes on button press in buttonUp.
function buttonUp_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NewArr;
global map;
global roleX;
global roleY;
global doorX;
global doorY;
global pixelH;
global pixelW;
global ground;
global door;
global start;
global win;
global roleUp;
global roleIndoor;
global roleWin;
global stepNow;
global noDoor;
% save last x,y
lastX = roleX;
lastY = roleY;


% set move
if roleY == 1
    set(handles.status,'string','Its bound, you can not move ');
else
    if noDoor == 0
        % into  door1
        if roleX == doorY(1) && roleY-1 == doorX(1)
            roleX = doorY(2);
            roleY = doorX(2);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % into  door2
        elseif roleX == doorY(2) && roleY-1 == doorX(2)
            roleX = doorY(1);
            roleY = doorX(1);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % not door and not wall
        elseif NewArr(roleY-1,roleX) ~= 0
            roleY = roleY - 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleUp;
            end
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving up');
            end
        elseif NewArr(roleY-1,roleX) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    else
        if NewArr(roleY-1,roleX) ~= 0
            roleY = roleY - 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleUp;
            end
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving up');
            end
        elseif NewArr(roleY-1,roleX) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    end
    % draw the map
    axes(handles.map);
    imshow(map); 
    
    % count step
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
end


% --- Executes on button press in buttonDown.
function buttonDown_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NewArr;
global map;
global row_length;
global roleX;
global roleY;
global doorX;
global doorY;
global pixelH;
global pixelW;
global ground;
global door;
global start;
global win;
global roleDown;
global roleIndoor;
global roleWin;
global stepNow;
global noDoor;
% save last x,y
lastX = roleX;
lastY = roleY;

% set move
if roleY == row_length
    set(handles.status,'string','Its bound, you can not move ');
else
    if noDoor == 0
        % into  door1
        if roleX == doorY(1) && roleY+1 == doorX(1)
            roleX = doorY(2);
            roleY = doorX(2);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % into  door2
        elseif roleX == doorY(2) && roleY+1 == doorX(2)
            roleX = doorY(1);
            roleY = doorX(1);
            map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleIndoor;
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            set(handles.status,'string','Into door');
        % not door and not wall
        elseif NewArr(roleY+1,roleX) ~= 0
            roleY = roleY + 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleDown;
            end
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving down');
            end
        elseif NewArr(roleY+1,roleX) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    else
        if NewArr(roleY+1,roleX) ~= 0
            roleY = roleY + 1;
            if NewArr(roleY,roleX) == 8
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleWin;
            else
                map((roleY-1)*pixelH+1 : (roleY)*pixelH , (roleX-1)*pixelW+1 : (roleX)*pixelW,:)  = roleDown;
            end
            % get last img
            lastImg = NewArr(lastY,lastX);
            switch lastImg
                case 1
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = ground;
                case 2
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = door;
                case 9
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = start;
                case 8
                    map((lastY-1)*pixelH+1 : (lastY)*pixelH , (lastX-1)*pixelW+1 : (lastX)*pixelW,:)  = win;
            end
            stepNow = stepNow + 1;
            if NewArr(roleY,roleX) == 8
                set(handles.status,'string','Win!!');
            else
                set(handles.status,'string','Moving down');
            end
        elseif NewArr(roleY+1,roleX) == 0
            set(handles.status,'string','It is wall, you can not move');
        end
    end
   % draw the map
    axes(handles.map);
    imshow(map); 
    
    % count step
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
end





function routeNum_Callback(hObject, eventdata, handles)
% hObject    handle to routeNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of routeNum as text
%        str2double(get(hObject,'String')) returns contents of routeNum as a double


% --- Executes during object creation, after setting all properties.
function routeNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to routeNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lengthNum_Callback(hObject, eventdata, handles)
% hObject    handle to lengthNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lengthNum as text
%        str2double(get(hObject,'String')) returns contents of lengthNum as a double


% --- Executes during object creation, after setting all properties.
function lengthNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lengthNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stepNum_Callback(hObject, eventdata, handles)
% hObject    handle to stepNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepNum as text
%        str2double(get(hObject,'String')) returns contents of stepNum as a double


% --- Executes during object creation, after setting all properties.
function stepNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in buttonShortest.
function buttonShortest_Callback(hObject, eventdata, handles)
% hObject    handle to buttonShortest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ansArr2;
global route_length2;
global minMap;
global minNum
% load img
global ground;
global wall;
global door;
global grass;
global startRole;
global win;
% load map data 
global pixelH;
global pixelW;
global row_length;
global col_length;
global roleX;
global roleY;
% load now map and set status
global nowMap;
global throughDoor;
global viewShortest;
global nowMinnum;

% if no path or not
global noPath;
if noPath == 0
    % find min map and data
    minLength = min(route_length2);
    minMap = find(route_length2 == minLength);
    minNum = length(minMap);
    
    % set status
    viewShortest = 1;
    throughDoor = 0;
    nowMinnum = 1;
    nowMap = minMap(nowMinnum);
    % print map
    global map;
    for i=1:row_length
        for j=1:col_length
            switch ansArr2(i,j,nowMap)
                case 0
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
                case 1
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
                case 2
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;
                case 5
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = grass; 
                case 9
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
                case 8
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
            end
        end
    end
    axes(handles.map);
    imshow(map); 

    % about role
    global stepNow;
    global startX;
    global startY;
    stepNow = 0;
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
    roleX = startX;
    roleY = startY;

    % print
    global shortestString;
    shortestString = num2str(minNum);
    shortestString = strcat('/',shortestString);
    s = strcat('1',shortestString)
    set(handles.routeNum,'string',s);

    len = num2str(route_length2(nowMap));
    set(handles.lengthNum,'string',len);

    set(handles.status,'string','Find shortest path from all');
else
    set(handles.routeNum,'string','0');
end

% --- Executes on button press in buttonTrans.
function buttonTrans_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ansArr;
global route_length;
global minMap;
global minNum;
% load img
global ground;
global wall;
global door;
global grass;
global startRole;
global win;
% load map data 
global pixelH;
global pixelW;
global row_length;
global col_length;
global roleX;
global roleY;
% load now map and set status
global nowMap;
global throughDoor;
global viewShortest;
global nowMinnum;

global noPath;
if noPath == 0
    % find min map and data
    minLength = min(route_length);
    minMap = find(route_length == minLength);
    minNum=length(minMap);

    % set status
    throughDoor = 1;
    viewShortest = 0;
    nowMinnum = 1;
    nowMap = minMap(nowMinnum);

    % print map
    global map;
    for i=1:row_length
        for j=1:col_length
            switch ansArr(i,j,nowMap)
                case 0
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
                case 1
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
                case 2
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;
                case 5
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = grass; 
                case 9
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
                case 8
                    map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
            end
        end
    end
    axes(handles.map);
    imshow(map); 

    % about role
    global stepNow;
    global startX;
    global startY;
    stepNow = 0;
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
    roleX = startX;
    roleY = startY;

    % print
    global doorString;
    doorString = num2str(minNum);
    doorString = strcat('/',doorString);
    s = strcat('1',doorString)
    set(handles.routeNum,'string',s);
    
    len = num2str(route_length(nowMap));
    set(handles.lengthNum,'string',len);

    set(handles.status,'string','Find shortest path through door');
else
    set(handles.routeNum,'string','0');
end

% --- Executes on button press in buttonNext.
function buttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load img
global ground;
global wall;
global door;
global grass;
global startRole;
global win;
% load map data 
global pixelH;
global pixelW;
global row_length;
global col_length;
global ansArr;
global ansArr2;
global route_num2;
global roleX;
global roleY;
global route_length;
global route_length2;
% load now map and get status
global map;
global nowMap;
global throughDoor;
global viewShortest;
global nowMinnum;
global minMap;
global minNum;

global noPath;
if noPath == 0
    % print map in throughDoor status
    if throughDoor == 1
        nowMinnum = nowMinnum + 1;
        if nowMinnum == minNum + 1
            nowMinnum = 1;
        end
        nowMap = minMap(nowMinnum);
        for i=1:row_length
            for j=1:col_length
                switch ansArr(i,j,nowMap)
                    case 0
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
                    case 1
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
                    case 2
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;
                    case 5
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = grass; 
                    case 9
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
                    case 8
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
                end
            end
        end
        len = num2str(route_length(nowMap));
    else
        % print map in viewShortest status
        if viewShortest == 1
            nowMinnum = nowMinnum + 1;
            if nowMinnum == minNum + 1
                nowMinnum = 1;
            end
            nowMap = minMap(nowMinnum);
        % print map in common status
        else
            nowMap = nowMap + 1;
            if nowMap == route_num2 + 1 
                nowMap = 1;
            end
        end

        for i=1:row_length
            for j=1:col_length
                switch ansArr2(i,j,nowMap)
                    case 0
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
                    case 1
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
                    case 2
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;
                    case 5
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = grass; 
                    case 9
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
                    case 8
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
                end
            end
        end
        len = num2str(route_length2(nowMap));
    end

    axes(handles.map);
    imshow(map); 

    % about role
    global stepNow;
    global startX;
    global startY;
    stepNow = 0;
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
    roleX = startX;
    roleY = startY;

    % print 
    global commonString;
    global shortestString;
    global doorString;
    if throughDoor == 1 
        index = num2str(nowMinnum);
        s = strcat(index,doorString);
    elseif viewShortest == 1
        index = num2str(nowMinnum);
        s = strcat(index,shortestString);
    else
        index = num2str(nowMap);
        s = strcat(index,commonString);
    end
    set(handles.routeNum,'string',s);

    set(handles.lengthNum,'string',len);

    set(handles.status,'string','Next route');
else
    set(handles.routeNum,'string','0');
end

% --- Executes on button press in buttonPrevious.
function buttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load img
global ground;
global wall;
global door;
global grass;
global startRole;
global win;
% load map data 
global pixelH;
global pixelW;
global row_length;
global col_length;
global ansArr;
global ansArr2;
global route_num2;
global roleX;
global roleY;
global route_length;
global route_length2;
% load now map and get status
global map;
global nowMap;
global throughDoor;
global viewShortest;
global nowMinnum;
global minMap;
global minNum;

global noPath;
if noPath == 0
    % print map in throughDoor status
    if throughDoor == 1
        nowMinnum = nowMinnum - 1;
        if nowMinnum == 0
            nowMinnum = minNum;
        end
        nowMap = minMap(nowMinnum);
        for i=1:row_length
            for j=1:col_length
                switch ansArr(i,j,nowMap)
                    case 0
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
                    case 1
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
                    case 2
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;
                    case 5
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = grass; 
                    case 9
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
                    case 8
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
                end
            end
        end
        len = num2str(route_length(nowMap));
    else
        % print map in viewShortest status
        if viewShortest == 1
            nowMinnum = nowMinnum - 1 ;
            if nowMinnum == 0
                nowMinnum = minNum;
            end
            nowMap = minMap(nowMinnum);
        % print map in common status
        else
            nowMap = nowMap - 1;
            if nowMap <= 0 
                nowMap = route_num2;
            end
        end

        for i=1:row_length
            for j=1:col_length
                switch ansArr2(i,j,nowMap)
                    case 0
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
                    case 1
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
                    case 2
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;
                    case 5
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = grass; 
                    case 9
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
                    case 8
                        map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
                end
            end
        end
        len = num2str(route_length2(nowMap));
    end
    axes(handles.map);
    imshow(map); 

    % about role
    global stepNow;
    global startX;
    global startY;
    stepNow = 0;
    step = num2str(stepNow);
    set(handles.stepNum,'string',step);
    roleX = startX;
    roleY = startY;

    % print 
    global commonString;
    global shortestString;
    global doorString;
    if throughDoor == 1 
        index = num2str(nowMinnum);
        s = strcat(index,doorString);
    elseif viewShortest == 1
        index = num2str(nowMinnum);
        s = strcat(index,shortestString);
    else
        index = num2str(nowMap);
        s = strcat(index,commonString);
    end
    set(handles.routeNum,'string',s);

    set(handles.lengthNum,'string',len);

    set(handles.status,'string','Previous route');
else
    set(handles.routeNum,'string','0');
end



% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset now map and status
global map;
global nowMap;
global throughDoor;
global viewShortest;
nowMap = 0;
viewShortest = 0;
throughDoor = 0;

% reprint map
global ground;
global wall;
global door;
global startRole;
global win;
global pixelH;
global pixelW;
global row_length;
global col_length;
global NewArr;
for i=1:row_length
    for j=1:col_length
        switch NewArr(i,j)
            case 0
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = wall;
            case 1
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = ground;
            case 2
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = door;   
            case 9
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = startRole;
            case 8
                map((i-1)*pixelH+1 : i*pixelH,(j-1)*pixelW+1 : (j)*pixelW,:)  = win; 
        end
    end
end
axes(handles.map);
imshow(map); 

% for role control---------------------------------------------
global stepNow;
global roleX;
global roleY;
global startX;
global startY;
roleX=startX;
roleY=startY;
stepNow=0;
set(handles.stepNum,'string','0');

% print detail
global initialString;
global noPath;
set(handles.routeNum,'string',initialString);

set(handles.lengthNum,'string','0');

if noPath == 1
    set(handles.status,'string','No path !!');
else
    set(handles.status,'string','Reset map');
end
