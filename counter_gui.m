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
global BW  %����ȫ�ֱ���
global iscut
global amount
axes(handles.axes2);   %ʹ�õڶ���axes

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
Threshold=graythresh(Image);%���Ostu�����ֵ
Image_BW=im2bw(Image,Threshold);%ת��Ϊ��ֵͼ��

Image_BW_medfilt=medfilt2(Image_BW,[13,13]);%��ֵ�˲�������[13,13]Ϊ�˲���ģ���С

se=strel('disk',10);% ��̬ѧ�����еĽṹԪ�أ����Բ�� disk size=10
se1=strel('disk',3);%С�ĽṹԪ��,disk size=3

Image_BW_open=imopen(Image_BW_medfilt,se);%������

Image_BW_spur=bwmorph(Image_BW_open,'spur');%�Ƴ��̼�����
Image_BW_clean=bwmorph(Image_BW_spur,'clean');%�Ƴ���������

Imgae_BW_fill=imfill(Image_BW_clean,'holes');%�׶����

Image_BW_erode=imerode(Imgae_BW_fill,se1);%�ٴθ�ʴ


[Label Number]=bwlabel(Image_BW_erode,8);%��ֵͼ�������ǩ����
Array=bwlabel(Image_BW_erode,8);%Array���������ر�ǩ�ľ���
Sum=[];
for i=1:Number
    [r,c]=find(Array==i);%r,c��ʾ��i���
    rc=[r,c];
    Num=length(rc);%Num��ʾrc�������к����нϴ����  
    Sum([i])=Num;%Ѱ��ÿ������ĳ��Ⱥ�
end
if iscut==1
    bwAreaOpenBW = bwareaopen(Image_BW_erode,round(mean(Sum)/4.25),8);%��ֵ����!!!!!û�н��
else
    bwAreaOpenBW = bwareaopen(Image_BW_erode,round(mean(Sum)/5),8);%��ֵ����!!!!!û�н��
end

if iscut==1
    D=-bwdist(~bwAreaOpenBW);%����任
 
    Ld = watershed(D);%��ˮ��
   
    bw2 = bwAreaOpenBW;
    bw2(Ld == 0) = 0;
  
    mask = imextendedmin(D,2);
   
    D2 = imimposemin(D,mask);%�ָ�������м����С��
    Ld2 = watershed(D2);
    bw3 = bwAreaOpenBW;
    bw3(Ld2 == 0) = 0;%ʹ��Ծֲ��ľ�����С
    % imshow(bw3)
    FinalImage=bw3;
elseif iscut==2
    FinalImage=bwAreaOpenBW;
end

BW=FinalImage;

[Label Number]=bwlabel(FinalImage,8);

for i=1:Number
    [r,c]=find(Array==i);%r,c��ʾ��i���
    rc=[r,c];
    Num=length(rc);%Num��ʾrc�������к����нϴ����  
    Sum([i])=Num;%Ѱ��ÿ������ĳ��Ⱥ�
end
% amount=Number;
% fprintf('���Ƶ�ϸ����ĿΪ %d\n',amount);
amount=Number;
STATS = regionprops(Label,'Centroid');
centroids = cat(1, STATS.Centroid);
% imshow('1.jpg')
% imshow(Image)

set(handles.edit1,'String',num2str(amount));

axes(handles.axes1);%��������2

plot(centroids(:,1), centroids(:,2), 'r*')

hold off

axes(handles.axes2);%��������2
imshow(BW);




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BW  %���崦����ͼƬBW���ȫ�ֱ���
[filename,pathname,filterindex]=...
    uiputfile({'*.bmp';'*.tif';'*.png'},'save picture');
if filterindex==0
return  %���ȡ������������
else
str=[pathname filename];  %�ϳ�·��+�ļ���
axes(handles.axes2);  %ʹ�õڶ���axes
imwrite(BW,str);  %д��ͼƬ��Ϣ��������ͼƬ
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf)  %�رյ�ǰFigure���ھ��

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
global im   %����һ��ȫ�ֱ���im

[filename,pathname]=...
    uigetfile({'*.*';'*.bmp';'*.tif';'*.png'},'select picture');  %ѡ��ͼƬ·��
str=[pathname filename];  %�ϳ�·��+�ļ���
im=imread(str);   %��ȡͼƬ
axes(handles.axes1);  %ʹ�õ�һ��axes
imshow(im);  %��ʾͼƬ
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
