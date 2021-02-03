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
Sat_num     = str2num(D1(3:7));
Class       = D1(8);
Inter_Desg  = {str2num(D1(10:11)); str2num(D1(12:14));D1(15:17)};
Epoch_yr    = str2num(D1(19:20)); % Last two digits of year
Epoch_d     = str2num(D1(21:32)); % Day of the year and fractional portion of the day
MM_1        = str2num(D1(34:43)); % First Time Derivative of the Mean Motion
MM_1        = MM_1*((2*pi())/((24*60)^2)); %rad/min^2
dumb        = -1*numel(num2str(abs(str2num(D1(45:50)))));
MM_2        = str2num(D1(45:50))*10.^(str2num(D1(51:52)))*10^(dumb); % Second Time Derivative of Mean Motion
MM_1        = MM_1*((2*pi())/((24*60)^3)); %rad/min^3
dumb        = -1*numel(num2str(abs(str2num(D1(54:59)))));
BSTAR       = str2num(D1(54:59))*10.^(str2num(D1(60:61)))*10^(dumb); % BSTAR drag term [earth rad ^-1]
EP_typ      = D1(63); % Ephemeris type
el_num      = str2num(D1(65:68)); % Element number
checksum1   = D1(69);
% Line 2
i           = str2num(D2(9:16)); % Inclination [Degrees] 
i           = deg2rad(i); % Inclination [radians]
RA          = str2num(D2(18:25)); % Right Ascension of the Ascending Node [Degrees]
RA          = deg2rad(RA); %radians
dumb        = -1*numel(num2str(abs(str2num(D2(27:33)))));
e           = str2num(D2(27:33))*10^(dumb); % eccentricity
omega       = str2num(D2(35:42)); % Argument of Perigee [Degrees]
omega       = deg2rad(omega); %radians
Mo          = str2num(D2(44:51)); % Mean Anomaly [Degrees]
Mo          = deg2rad(Mo); %radians
no          = str2num(D2(53:63)); % Mean Motion [Revs per day]
no          = no*((2*pi())/(24*60*60)); % rad/sec
Rev         = str2num(D2(64:68)); % Revolution number at epoch [Revs]
checksum2   = D2(69);

%% Calculate Position and Velocity 
% reference: https://downloads.rene-schwarz.com/download/M001-Keplerian_Orbit_Elements_to_Cartesian_State_Vectors.pdf

mu_e        = 3.986*10^14;
a_e         = 149.6*(10^6)*1000; % semi major axis of earth [m]
e_e         = 0.0167086; %Earth eccentricity

a           = ((mu_e^.5)/no)^(2/2); % semi major axis [m]

% determine dt
year = 2000+Epoch_yr;
day = floor(Epoch_d);
fraction = Epoch_d-day;
month = 1;
test = 1;
while test
    if day > eomday(year,month)
        day = day - eomday(year,month);
        month = month+1;
    else 
        test = 0;
    end
end
hour = floor(24*fraction);
fraction = (24*fraction)-hour;
minute = floor(60*fraction);
fraction = (60*fraction)-minute;
second = 60*fraction;
jd = juliandate(year,month,day,hour, minute,second);
jd_now = juliandate(datetime(now, 'ConvertFrom','datenum'));
dt = 86400*(jd_now-jd);

% calculate mean anomoly M_t
Mt = Mo + dt*sqrt(mu_e/(a^3));

%Solve Keplers Equation numerically
Eo = Mo;
Et = Eo - ((Eo-e*sin(Eo)-Mt)/(1-e*cos(Eo)));

% solve for true anomaly 
vt = 2*atan2(sqrt(1+e)*sin(Et/2),sqrt(1-e)*sin(Et/2));

% use E to get distance to central body
rc = a*(1-e*cos(Et));

% position and velocity in orbital frame (o, o_dot)
o = rc.*[cos(vt);sin(vt); 0];
o_dot = (sqrt(mu_e*a)/rc).*[-sin(Et);sqrt(1-e^2)*cos(Et);0];

% transform o and O_dot to inertial frame in earth centric coordinates 
% (r, r_dot w/ rotation matrices Rx, Rz)
r = [(o(1)*((cos(omega)*cos(RA))-(sin(omega)*sin(RA)*cos(i))))-(o(2)*((sin(omega)*cos(RA))+(cos(omega)*cos(i)*sin(RA))));
     (o(1)*((cos(omega)*sin(RA))+(sin(omega)*cos(RA)*cos(i))))+(o(2)*((cos(omega)*cos(i)*cos(RA))-(sin(omega)*sin(RA))));
     (o(1)*sin(omega*sin(i)))+(o(2)*cos(omega)*sin(i))];
 
r_dot = [(o_dot(1)*((cos(omega)*cos(RA))-(sin(omega)*sin(RA)*cos(i))))-(o_dot(2)*((sin(omega)*cos(RA))+(cos(omega)*cos(i)*sin(RA))));
         (o_dot(1)*((cos(omega)*sin(RA))+(sin(omega)*cos(RA)*cos(i))))+(o_dot(2)*((cos(omega)*cos(i)*cos(RA))-(sin(omega)*sin(RA))));
         (o_dot(1)*sin(omega*sin(i)))+(o_dot(2)*cos(omega)*sin(i))];

%% Print to File

ID = fopen('KERV.txt', 'w+');
fprintf(ID,'Keplerian Elements \n\n');
fprintf(ID,'Epoch Time:     %u / %u / %u  %u hrs, %u minutes, %.2f sec \n', month,day,year,hour, minute,second);
fprintf(ID,'Inclination:    %0.4f radians\n',i);
fprintf(ID,'RAAN:           %0.4f radians\n',RA);
fprintf(ID,'Eccentricity:   %0.4f \n',e);
fprintf(ID,'Arg of Perigee: %0.4f radians\n',omega);
fprintf(ID,'Mean Motion:    %0.4f radians/sec\n',no);
fprintf(ID,'Mean Anomaly:   %0.4f radians\n',Mo);
fprintf(ID,'BSTAR:          %0.4f earth rad ^-1\n',BSTAR);
fprintf(ID,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
fprintf(ID,'Cartesian State Vectors\n\n');
fprintf(ID,'r =     %.4f m\n',r(1));
fprintf(ID,'        %.4f m\n',r(2));
fprintf(ID,'        %.4f m\n',r(3));
fprintf(ID,'r_dot = %.4f m/s\n',r_dot(1));
fprintf(ID,'        %.4f m/s\n',r_dot(2));
fprintf(ID,'        %.4f m/s',r_dot(3));
fclose(ID);