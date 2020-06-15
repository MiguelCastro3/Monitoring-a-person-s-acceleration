function varargout = Interface_BA(varargin)
% INTERFACE_BA MATLAB code for Interface_BA.fig
%      INTERFACE_BA, by itself, creates a new INTERFACE_BA or raises the existing
%      singleton*.
%
%      H = INTERFACE_BA returns the handle to a new INTERFACE_BA or the handle to
%      the existing singleton*.
%
%      INTERFACE_BA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE_BA.M with the given input arguments.
%
%      INTERFACE_BA('Property','Value',...) creates a new INTERFACE_BA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Interface_BA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Interface_BA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Interface_BA

% Last Modified by GUIDE v2.5 28-Dec-2017 18:14:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Interface_BA_OpeningFcn, ...
                   'gui_OutputFcn',  @Interface_BA_OutputFcn, ...
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


% --- Executes just before Interface_BA is made visible.
function Interface_BA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Interface_BA (see VARARGIN)

% Choose default command line output for Interface_BA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Interface_BA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Interface_BA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Imagem e texto de apresenta��o
imagem = imread('logoUM.png');
axes(handles.axes4);
imshow(imagem);


% --- Executes on button press in pushbutton1. => BOT�O INICIAR
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%inicializa��o e caracter�sticas da porta s�rie
s = serial('COM3');
set(s, 'InputBufferSize', 1024);
set(s, 'FlowControl', 'none');
set(s, 'BaudRate', 9600);
set(s, 'Parity', 'none');
set(s, 'DataBits', 8);
set(s, 'StopBit', 2);
set(s, 'TimeOut', 30);
fopen(s);
CHECKPOINT = 'COME�OU'

%inicializa��o dos vetores
canal_ADC3 = zeros(10000000, 1); %ADC3
canal_ADC4 = zeros(10000000, 1); %ADC4
canal_ADC5 = zeros(10000000, 1); %ADC5
i = 1;

while(1) %cria��o de um ciclo infinito
    dados = fread(s, 91, 'char'); %leitura de um conjunto de 91 dados; 'char' retorna 91 valores entre 0 e 255   
    
    %caso o ADMUX do ADC3 seja o primeiro a aparecer
    if dados(1) == 195 %primeiro valor � a identifica��o do ADMUX e confirmar se corresponde a 0xC3 = 195 => ADC3   
        i = i + 1;
        ADCL_ADC3(1:10) = dados(2:9:91); %ADCL do ADC3 � enviado ap�s a identifica��o (2� posi��o)
        ADCH_ADC3(1:10) = dados(3:9:91); %ADCH do ADC3 � enviado ap�s ADCL (3� posi��o)
        for j = 1:10 %por cada 91 dados existem 30 identifica��es e 30 pares de dados, logo temos 10 convers�es para cada canal
            str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8); %convers�o de decimal para bin�rio (8 bits)
            str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8); %convers�o de decimal para bin�rio (8 bits)
            dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))'; %convers�o da string num vetor com 8 elementos
            dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))'; %convers�o da string num vetor com 8 elementos
            digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3]; %jun��o dos 2 bits mais significativos com os 8 bits menos significativos
            valor = bin2dec(num2str(digital)); %convers�o da palavra bin�ria de 10 bits em tens�o
            valor = 2.56 * valor / 1023; %normaliza��o para tens�o com refer�ncia a 2.56V
            valores_ADC3(j) = valor; %conjunto dos 10 valores de tens�o
        end
        canal_ADC3(i:i+9) = valores_ADC3; %coloca os 10 valores calculados no respetivo vetor
             
        ADCL_ADC4(1:10) = dados(5:9:91); %ADCL do canal ADC3 � enviado ap�s a identifica��o (5� posi��o)
        ADCH_ADC4(1:10) = dados(6:9:91); %ADCH do canal ADC3 � enviado ap�s ADCL (6� posi��o)
        for j = 1:10
            str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8); %converte o ADCL para bin�rio, de 8 bits
            str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8); %converte o ADCH para bin�rio, de 8 bits
            dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))'; %converte o ADCL para n�mero
            dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))'; %converte o ADCH para n�mero
            digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4]; %concatena��o dos 10 bits
            valor = bin2dec(num2str(digital)); %convers�o do valor para decimal
            valor = 2.56 * valor / 1023; %normaliza��o dos ficheiros 
            valores_ADC4(j) = valor;
        end
        canal_ADC4(i:i+9) = valores_ADC4; %jun��o dos 10 valores convertidos
        
        ADCL_ADC5(1:10) = dados(8:9:91); %ADCL do canal ADC3 � enviado ap�s a identifica��o (8� posi��o)
        ADCH_ADC5(1:10) = dados(9:9:91); %ADCH do canal ADC3 � enviado ap�s ADCL (9� posi��o)
        for j = 1:10
            str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
            str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
            dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
            dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
            digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
            valor = bin2dec(num2str(digital));
            valor = 2.56 * valor / 1023;
            valores_ADC5(j) = valor;
        end
        canal_ADC5(i:i+9) = valores_ADC5;
        
        i = i + 9; %incrementa o contador para que no pr�ximo ciclo n�o se aloquem em valores de tens�o j� ocupados

        if i >= 500 %apenas faz o plot quando tiver mais de 500 amostras
            axes(handles.axes1)
            plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize); %legenda
            ylabel('Tens�o(V)', 'FontSize', fontSize); %legenda
            ylim([0 2.56]); %limita��o dos eixos, iguais para todos de modo a facilitar compara��es
            grid on %aparecer uma grelha de forma a facilitar a visualiza��o
            drawnow %necess�rio para a visualiza��o

            axes(handles.axes2)
            plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on
            drawnow

            axes(handles.axes3)
            plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on
            drawnow
        end
        
        
    elseif dados(1) == 196  %identifica��o do ADMUX e confirmar se corresponde a 0xC4 = 196 => ADC4
        i = i + 1;
        ADCL_ADC4(1:10) = dados(2:9:91);
        ADCH_ADC4(1:10) = dados(3:9:91);
        for j = 1:10
            str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
            str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
            dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
            dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
            digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
            valor = bin2dec(num2str(digital));
            valor = 2.56 * valor / 1023;
            valores_ADC4(j) = valor;
        end
        canal_ADC4(i:i+9) = valores_ADC4;
             
        ADCL_ADC5(1:10) = dados(5:9:91);
        ADCH_ADC5(1:10) = dados(6:9:91);
        for j = 1:10
            str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
            str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
            dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
            dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
            digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
            valor = bin2dec(num2str(digital));
            valor = 2.56 * valor / 1023;
            valores_ADC5(j) = valor;
        end
        canal_ADC5(i:i+9) = valores_ADC5;
        
        ADCL_ADC3(1:10) = dados(8:9:91);
        ADCH_ADC3(1:10) = dados(9:9:91);
        for j = 1:10
            str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8);
            str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8);
            dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))';
            dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))';
            digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3];
            valor = bin2dec(num2str(digital));
            valor = 2.56 * valor / 1023;
            valores_ADC3(j) = valor;
        end
        canal_ADC3(i:i+9) = valores_ADC3;
        
        i = i + 9;

        if i >= 500
           axes(handles.axes1)
            plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on 
            drawnow

            axes(handles.axes2)
            plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on
            drawnow

            axes(handles.axes3)
            plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on
            drawnow
        end
        
        
    elseif dados(1) == 197  %identifica��o do ADMUX e confirmar se corresponde a 0xC5 = 197 => ADC5
        i = i + 1;
        ADCL_ADC5(1:10) = dados(2:9:91);
        ADCH_ADC5(1:10) = dados(3:9:91);
        for j = 1:10
            str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
            str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
            dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
            dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
            digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
            valor = bin2dec(num2str(digital));
            valor = 2.56 * valor / 1023;
            valores_ADC5(j) = valor;
        end
        canal_ADC5(i:i+9) = valores_ADC5;
             
        ADCL_ADC3(1:10) = dados(5:9:91);
        ADCH_ADC3(1:10) = dados(6:9:91);
        for j = 1:10
            str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8);
            str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8);
            dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))';
            dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))';
            digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3];
            valor = bin2dec(num2str(digital));
            valor = 2.56 * valor / 1023;
            valores_ADC3(j) = valor;
        end
        canal_ADC3(i:i+9) = valores_ADC3;
        
        ADCL_ADC4(1:10) = dados(8:9:91);
        ADCH_ADC4(1:10) = dados(9:9:91);
        for j = 1:10
            str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
            str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
            dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
            dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
            digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
            valor = bin2dec(num2str(digital));
            valor = 2.56 * valor / 1023;
            valores_ADC4(j) = valor;
        end
        canal_ADC4(i:i+9) = valores_ADC4;
        
        i = i + 9;
    
        %visualiza��o dos dados na interface atrav�s axes e plots
        if i >= 500
            axes(handles.axes1)
            plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on 
            drawnow

            axes(handles.axes2)
            plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on
            drawnow

            axes(handles.axes3)
            plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
            fontSize = 10;
            xlabel('Tempo(s)', 'FontSize', fontSize);
            ylabel('Tens�o(V)', 'FontSize', fontSize);
            ylim([0 2.56]);
            grid on
            drawnow
        end
    
        
        
        
    %caso o ADMUX do ADC4 seja o primeiro a aparecer    
    else
        if dados(2) == 195 %primeiro valor � a identifica��o do ADMUX e confirmar se corresponde a 0xC3 = 195 => ADC3   
            i = i + 1;
            ADCL_ADC3(1:10) = dados(3:9:91); %ADCL do ADC3 � enviado ap�s a identifica��o (2� posi��o)
            ADCH_ADC3(1:10) = dados(4:9:91); %ADCH do ADC3 � enviado ap�s ADCL (3� posi��o)
            for j = 1:10 %por cada 91 dados existem 30 identifica��es e 30 pares de dados, logo temos 10 convers�es para cada canal
                str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8); %convers�o de decimal para bin�rio (8 bits)
                str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8); %convers�o de decimal para bin�rio (8 bits)
                dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))'; %convers�o da string num vetor com 8 elementos
                dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))'; %convers�o da string num vetor com 8 elementos
                digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3]; %jun��o dos 2 bits mais significativos com os 8 bits menos significativos
                valor = bin2dec(num2str(digital)); %convers�o da palavra bin�ria de 10 bits em tens�o 
                valor = 2.56 * valor / 1023; %normaliza��o para tens�o com refer�ncia a 2.56V
                valores_ADC3(j) = valor; %conjunto dos 10 valores de tens�o
            end
            canal_ADC3(i:i+9) = valores_ADC3; %coloca os 10 valores calculados no respetivo vetor

            ADCL_ADC4(1:10) = dados(6:9:91); %ADCL do canal ADC3 � enviado ap�s a identifica��o (5� posi��o)
            ADCH_ADC4(1:10) = dados(7:9:91); %ADCH do canal ADC3 � enviado ap�s ADCL (6� posi��o)
            for j = 1:10
                str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
                str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
                dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
                dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
                digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC4(j) = valor;
            end
            canal_ADC4(i:i+9) = valores_ADC4;

            ADCL_ADC5(1:10) = dados(9:9:91); %ADCL do canal ADC3 � enviado ap�s a identifica��o (8� posi��o)
            ADCH_ADC5(1:10) = dados(10:9:91); %ADCH do canal ADC3 � enviado ap�s ADCL (9� posi��o)
            for j = 1:10
                str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
                str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
                dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
                dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
                digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC5(j) = valor;
            end
            canal_ADC5(i:i+9) = valores_ADC5;

            i = i + 9; %incrementa o contador para que no pr�ximo ciclo n�o se aloquem em valores de tens�o j� ocupados

            if i >= 500
                axes(handles.axes1)
                plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow

                axes(handles.axes2)
                plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
                
                axes(handles.axes3)
                plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
            end


        elseif dados(2) == 196  %identifica��o do ADMUX e confirmar se corresponde a 0xC4 = 196 => ADC4
            i = i + 1;
            ADCL_ADC4(1:10) = dados(3:9:91);
            ADCH_ADC4(1:10) = dados(4:9:91);
            for j = 1:10
                str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
                str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
                dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
                dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
                digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC4(j) = valor;
            end
            canal_ADC4(i:i+9) = valores_ADC4;

            ADCL_ADC5(1:10) = dados(6:9:91);
            ADCH_ADC5(1:10) = dados(7:9:91);
            for j = 1:10
                str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
                str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
                dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
                dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
                digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC5(j) = valor;
            end
            canal_ADC5(i:i+9) = valores_ADC5;

            ADCL_ADC3(1:10) = dados(9:9:91);
            ADCH_ADC3(1:10) = dados(10:9:91);
            for j = 1:10
                str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8);
                str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8);
                dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))';
                dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))';
                digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC3(j) = valor;
            end
            canal_ADC3(i:i+9) = valores_ADC3;

            i = i + 9;

            if i >= 500
                axes(handles.axes1)
                plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow

                axes(handles.axes2)
                plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
                
                axes(handles.axes3)
                plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
            end


        elseif dados(2) == 197  %identifica��o do ADMUX e confirmar se corresponde a 0xC5 = 197 => ADC5
            i = i + 1;
            ADCL_ADC5(1:10) = dados(3:9:91);
            ADCH_ADC5(1:10) = dados(4:9:91);
            for j = 1:10
                str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
                str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
                dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
                dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
                digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC5(j) = valor;
            end
            canal_ADC5(i:i+9) = valores_ADC5;

            ADCL_ADC3(1:10) = dados(6:9:91);
            ADCH_ADC3(1:10) = dados(7:9:91);
            for j = 1:10
                str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8);
                str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8);
                dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))';
                dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))';
                digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC3(j) = valor;
            end
            canal_ADC3(i:i+9) = valores_ADC3;

            ADCL_ADC4(1:10) = dados(9:9:91);
            ADCH_ADC4(1:10) = dados(10:9:91);
            for j = 1:10
                str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
                str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
                dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
                dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
                digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC4(j) = valor;
            end
            canal_ADC4(i:i+9) = valores_ADC4;

            i = i + 9;

            %visualiza��o dos dados na interface atrav�s axes e plots
            if i >= 500
                axes(handles.axes1)
                plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow

                axes(handles.axes2)
                plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
                
                axes(handles.axes3)
                plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
            end
            
        
        
        
    %caso o ADMUX do ADC5 seja o primeiro a aparecer      
    else
        if dados(3) == 195 %primeiro valor � a identifica��o do ADMUX e confirmar se corresponde a 0xC3 = 195 => ADC3   
            i = i + 1;
            ADCL_ADC3(1:10) = dados(4:9:91); %ADCL do ADC3 � enviado ap�s a identifica��o (2� posi��o)
            ADCH_ADC3(1:10) = dados(5:9:91); %ADCH do ADC3 � enviado ap�s ADCL (3� posi��o)
            for j = 1:10 %por cada 91 dados existem 30 identifica��es e 30 pares de dados, logo temos 10 convers�es para cada canal
                str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8); %convers�o de decimal para bin�rio (8 bits)
                str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8); %convers�o de decimal para bin�rio (8 bits)
                dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))'; %convers�o da string num vetor com 8 elementos
                dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))'; %convers�o da string num vetor com 8 elementos
                digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3]; %jun��o dos 2 bits mais significativos com os 8 bits menos significativos
                valor = bin2dec(num2str(digital)); %convers�o da palavra bin�ria de 10 bits em tens�o
                valor = 2.56 * valor / 1023; %normaliza��o para tens�o com refer�ncia a 2.56V
                valores_ADC3(j) = valor; %conjunto dos 10 valores de tens�o
            end
            canal_ADC3(i:i+9) = valores_ADC3; %coloca os 10 valores calculados no respetivo vetor

            ADCL_ADC4(1:10) = dados(7:9:91); %ADCL do canal ADC3 � enviado ap�s a identifica��o (5� posi��o)
            ADCH_ADC4(1:10) = dados(8:9:91); %ADCH do canal ADC3 � enviado ap�s ADCL (6� posi��o)
            for j = 1:10
                str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
                str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
                dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
                dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
                digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC4(j) = valor;
            end
            canal_ADC4(i:i+9) = valores_ADC4;

            ADCL_ADC5(1:10) = dados(1:9:90); %ADCL do canal ADC3 � enviado ap�s a identifica��o (8� posi��o)
            ADCH_ADC5(1:10) = dados(2:9:90); %ADCH do canal ADC3 � enviado ap�s ADCL (9� posi��o)
            for j = 1:10
                str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
                str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
                dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
                dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
                digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC5(j) = valor;
            end
            canal_ADC5(i:i+9) = valores_ADC5;

            i = i + 9; %incrementa o contador para que no pr�ximo ciclo n�o se aloquem em valores de tens�o j� ocupados

            if i >= 500
                axes(handles.axes1)
                plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow

                axes(handles.axes2)
                plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
                
                axes(handles.axes3)
                plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
            end


        elseif dados(3) == 196  %identifica��o do ADMUX e confirmar se corresponde a 0xC4 = 196 => ADC4
            i = i + 1;
            ADCL_ADC4(1:10) = dados(4:9:91);
            ADCH_ADC4(1:10) = dados(5:9:91);
            for j = 1:10
                str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
                str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
                dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
                dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
                digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC4(j) = valor;
            end
            canal_ADC4(i:i+9) = valores_ADC4;

            ADCL_ADC5(1:10) = dados(7:9:91);
            ADCH_ADC5(1:10) = dados(8:9:91);
            for j = 1:10
                str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
                str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
                dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
                dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
                digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC5(j) = valor;
            end
            canal_ADC5(i:i+9) = valores_ADC5;

            ADCL_ADC3(1:10) = dados(1:9:90);
            ADCH_ADC3(1:10) = dados(2:9:90);
            for j = 1:10
                str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8);
                str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8);
                dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))';
                dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))';
                digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC3(j) = valor;
            end
            canal_ADC3(i:i+9) = valores_ADC3;

            i = i + 9;

            if i >= 500
                axes(handles.axes1)
                plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow

                axes(handles.axes2)
                plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
                
                axes(handles.axes3)
                plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
            end


        elseif dados(3) == 197  %identifica��o do ADMUX e confirmar se corresponde a 0xC5 = 197 => ADC5
            i = i + 1;
            ADCL_ADC5(1:10) = dados(4:9:91);
            ADCH_ADC5(1:10) = dados(5:9:91);
            for j = 1:10
                str_ADCL_ADC5 = dec2bin(ADCL_ADC5(j), 8);
                str_ADCH_ADC5 = dec2bin(ADCH_ADC5(j), 8);
                dig_ADCL_ADC5 = str2num(str_ADCL_ADC5(:))';
                dig_ADCH_ADC5 = str2num(str_ADCH_ADC5(:))';
                digital = [dig_ADCH_ADC5(7) dig_ADCH_ADC5(8) dig_ADCL_ADC5];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC5(j) = valor;
            end
            canal_ADC5(i:i+9) = valores_ADC5;

            ADCL_ADC3(1:10) = dados(7:9:91);
            ADCH_ADC3(1:10) = dados(8:9:91);
            for j = 1:10
                str_ADCL_ADC3 = dec2bin(ADCL_ADC3(j), 8);
                str_ADCH_ADC3 = dec2bin(ADCH_ADC3(j), 8);
                dig_ADCL_ADC3 = str2num(str_ADCL_ADC3(:))';
                dig_ADCH_ADC3 = str2num(str_ADCH_ADC3(:))';
                digital = [dig_ADCH_ADC3(7) dig_ADCH_ADC3(8) dig_ADCL_ADC3];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC3(j) = valor;
            end
            canal_ADC3(i:i+9) = valores_ADC3;

            ADCL_ADC4(1:10) = dados(1:9:90);
            ADCH_ADC4(1:10) = dados(2:9:90);
            for j = 1:10
                str_ADCL_ADC4 = dec2bin(ADCL_ADC4(j), 8);
                str_ADCH_ADC4 = dec2bin(ADCH_ADC4(j), 8);
                dig_ADCL_ADC4 = str2num(str_ADCL_ADC4(:))';
                dig_ADCH_ADC4 = str2num(str_ADCH_ADC4(:))';
                digital = [dig_ADCH_ADC4(7) dig_ADCH_ADC4(8) dig_ADCL_ADC4];
                valor = bin2dec(num2str(digital));
                valor = 2.56 * valor / 1023;
                valores_ADC4(j) = valor;
            end
            canal_ADC4(i:i+9) = valores_ADC4;

            i = i + 9;

            %visualiza��o dos dados na interface atrav�s axes e plots
            if i >= 500
                axes(handles.axes1)
                plot((i-500:1:i-1)/90, canal_ADC3(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow

                axes(handles.axes2)
                plot((i-500:1:i-1)/90, canal_ADC4(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
                
                axes(handles.axes3)
                plot((i-500:1:i-1)/90, canal_ADC5(i-500:1:i-1));
                fontSize = 10;
                xlabel('Tempo(s)', 'FontSize', fontSize);
                ylabel('Tens�o(V)', 'FontSize', fontSize);
                ylim([0 2.56]);
                grid on
                drawnow
            end
        end
    end
    end
end


% --- Executes on button press in pushbutton2. => BOT�O TERMINAR
function pushbutton2_Callback(hObject, eventdata, handles)
CHECKPOINT = 'TERMINOU'
fclose(instrfind);
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


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
