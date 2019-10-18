function varargout = jiemian(varargin)
% JIEMIAN M-file for jiemian.fig
%      JIEMIAN, by itself, creates a new JIEMIAN or raises the existing
%      singleton*.
%
%      H = JIEMIAN returns the handle to a new JIEMIAN or the handle to
%      the existing singleton*.
%
%      JIEMIAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JIEMIAN.M with the given input arguments.
%
%      JIEMIAN('Property','Value',...) creates a new JIEMIAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jiemian_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jiemian_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jiemian

% Last Modified by GUIDE v2.5 24-Dec-2014 20:31:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jiemian_OpeningFcn, ...
                   'gui_OutputFcn',  @jiemian_OutputFcn, ...
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


% --- Executes just before jiemian is made visible.
function jiemian_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jiemian (see VARARGIN)

% Choose default command line output for jiemian
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jiemian wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.axes1,'visible','off')
set(handles.axes2,'visible','off')

% --- Outputs from this function are returned to the command line.
function varargout = jiemian_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global im
global BW  %定义全局变量
global iscut
global amount
axes(handles.axes2);   %使用第二个axes

mysize=size(im);

if numel(mysize)>2
    im1=rgb2gray(im);
else
    im1=im;
end
if iscut==1
    Image=imadjust(im1,[0.2,0.6]);
else
    Image=im1;
end
Threshold=graythresh(Image);%求出Ostu最佳阈值
Image_BW=im2bw(Image,Threshold);%转化为二值图像

Image_BW_medfilt=medfilt2(Image_BW,[13,13]);%中值滤波操作，[13,13]为滤波器模板大小

se=strel('disk',10);% 形态学运算中的结构元素，大的圆盘 disk size=10
se1=strel('disk',3);%小的结构元素,disk size=3

Image_BW_open=imopen(Image_BW_medfilt,se);%开操作

Image_BW_spur=bwmorph(Image_BW_open,'spur');%移除刺激像素
Image_BW_clean=bwmorph(Image_BW_spur,'clean');%移除孤立像素

Imgae_BW_fill=imfill(Image_BW_clean,'holes');%孔洞填充

Image_BW_erode=imerode(Imgae_BW_fill,se1);%再次腐蚀


[Label Number]=bwlabel(Image_BW_erode,8);%二值图像的贴标签操作
Array=bwlabel(Image_BW_erode,8);%Array数组是像素标签的矩阵
Sum=[];
for i=1:Number
    [r,c]=find(Array==i);%r,c表示第i类的
    rc=[r,c];
    Num=length(rc);%Num表示rc矩阵中行和列中较大的数  
    Sum([i])=Num;%寻找每个分类的长度和
end
if iscut==1
    bwAreaOpenBW = bwareaopen(Image_BW_erode,round(mean(Sum)/4.25),8);%阈值问题!!!!!没有解决
else
    bwAreaOpenBW = bwareaopen(Image_BW_erode,round(mean(Sum)/5),8);%阈值问题!!!!!没有解决
end

if iscut==1
    D=-bwdist(~bwAreaOpenBW);%距离变换
 
    Ld = watershed(D);%分水岭
   
    bw2 = bwAreaOpenBW;
    bw2(Ld == 0) = 0;
  
    mask = imextendedmin(D,2);
   
    D2 = imimposemin(D,mask);%分割的区块中间产生小点
    Ld2 = watershed(D2);
    bw3 = bwAreaOpenBW;
    bw3(Ld2 == 0) = 0;%使其对局部的距离最小
    % imshow(bw3)
    FinalImage=bw3;
elseif iscut==2
    FinalImage=bwAreaOpenBW;
end

BW=FinalImage;

[Label Number]=bwlabel(FinalImage,8);

for i=1:Number
    [r,c]=find(Array==i);%r,c表示第i类的
    rc=[r,c];
    Num=length(rc);%Num表示rc矩阵中行和列中较大的数  
    Sum([i])=Num;%寻找每个分类的长度和
end
% amount=Number;
% fprintf('估计的细胞数目为 %d\n',amount);
amount=Number;
STATS = regionprops(Label,'Centroid');
centroids = cat(1, STATS.Centroid);
% imshow('1.jpg')
% imshow(Image)

set(handles.edit1,'String',num2str(amount));

axes(handles.axes1);%绘制曲线2

plot(centroids(:,1), centroids(:,2), 'r*')

hold off

axes(handles.axes2);%绘制曲线2
imshow(BW);




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BW  %定义处理后的图片BW这个全局变量
[filename,pathname,filterindex]=...
    uiputfile({'*.bmp';'*.tif';'*.png'},'save picture');
if filterindex==0
return  %如果取消操作，返回
else
str=[pathname filename];  %合成路径+文件名
axes(handles.axes2);  %使用第二个axes
imwrite(BW,str);  %写入图片信息，即保存图片
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf)  %关闭当前Figure窗口句柄

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

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


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global im   %定义一个全局变量im

[filename,pathname]=...
    uigetfile({'*.*';'*.bmp';'*.tif';'*.png'},'select picture');  %选择图片路径
str=[pathname filename];  %合成路径+文件名
im=imread(str);   %读取图片
axes(handles.axes1);  %使用第一个axes
imshow(im);  %显示图片
hold on;

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global iscut
% Hint: get(hObject,'Value') returns toggle state of radiobutton3
set(handles.radiobutton2,'value',0);
set(handles.radiobutton3,'value',1);
iscut=2;

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
global iscut
set(handles.radiobutton2,'value',1);
set(handles.radiobutton3,'value',0);
iscut=1;

% --- Executes during object creation, after setting all properties.
function uipanel3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
