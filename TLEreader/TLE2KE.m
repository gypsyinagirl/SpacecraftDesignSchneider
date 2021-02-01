%%%%%%%%%%%%%%%%%%
% Emma Schneider %
% AA 236A        %
%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;

%% Reading the text file

ID = fopen('TLE.txt','r');
fseek(ID, -1, 'cof');
D0 = fscanf(ID,'%*1c %22c',1);
D1 = fscanf(ID,'%*1c %69c',1);
D2 = fscanf(ID,'%*1c %69c',1);
fclose(ID);

%% Assigning Values
% Line 1
Sat_num     =  str2num(D1(3:7));
Class       = D1(8);
Inter_Desg  = {str2num(D1(10:11)); str2num(D1(12:14));D1(15:17)};
Epoch_yr    = str2num(D1(19:20));
Epoch_d     = str2num(D1(21:32));
MM_1        = str2num(D1(34:43));
MM_2        = str2num(D1(45:50))*10.^(str2num(D1(51:52)));
dumb        = -1*numel(num2str(abs(str2num(D1(54:59)))));
BSTAR       = str2num(D1(54:59))*10.^(str2num(D1(60:61)))*10^(dumb);
EP_typ      = D1(63);
el_num      = str2num(D1(65:68));
checksum1   = D1(69);
% Line 2
Incl        = str2num(D2(9:16));
RA          = str2num(D2(18:25));
dumb        = -1*numel(num2str(abs(str2num(D2(27:33)))));
e           = str2num(D2(27:33))*10^(dumb);
peri_arg    = str2num(D2(35:42));
M_anon      = str2num(D2(44:51));
MM          = str2num(D2(53:63));
Rev         = str2num(D2(64:68));
checksum2   = D2(69);





