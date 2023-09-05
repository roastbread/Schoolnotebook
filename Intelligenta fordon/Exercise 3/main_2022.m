%
% Main script that reads controller data and laser data
%
clear all;
close all;


% Co-ordinates of the ref. nodes
REF = [1920 9470;   % 01
       10012 8179;  % 02
       9770 7590;   % 03
       11405 7228;  % 04
       11275 6451;  % 05
       11628 6384.5;% 06
       11438 4948;  % 07
       8140 8274;   % 08
       8392 8486;   % 09
       3280 2750;   % 10
       7250 2085;   % 11
       9990 1620;   % 12
       7485 3225;   % 13
       9505 3893;   % 14
       9602 4278;   % 15
       10412 4150;  % 16
       4090 7920;   % 17
       8010 5290;   % 18
       8255 6099;   % 19
       7733 6151;   % 20
       7490 6136;   % 21
       7061 5420;   % 22
       7634 5342];  % 23

% LINE SEGMENT MODEL (Indeces in the REF-vector)
LINES = [1 8;       % L01
         9 2;       % L02
         2 3;       % L03
         3 4;       % L04
         4 5;       % L05
         5 6;       % L06
         6 7;       % L07
         17 10;     % L08
         10 12;     % L09
         11 13;     % L10
         12 16;     % L11
         16 15;     % L12
         15 14;     % L13
         19 21;     % L14
         22 18;     % L15
         20 23];    % L16
         
% Control inputs (velocity and steering angle)
CONTROL = load('control_joy.txt');

% Laser data
LD_HEAD   = load('laser_header.txt');
LD_ANGLES = load('laser_angles.txt');
LD_MEASUR = load('laser_measurements.txt');
LD_FLAGS  = load('laser_flags.txt');

[no_inputs co] = size(CONTROL);

% Robots initial position
X(1) = CONTROL(1,4);
Y(1) = CONTROL(1,5);
A(1) = CONTROL(1,6);
P(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2]; %p-value = covariance matrix for x y theta
Sigmahat(1,1:9) = P(1);
scan_idx = 1;
fig_path = figure;
fig_env = figure;

sig1 = (10)*10^(-3);
sig2 = (10)*10^(-3); 
sig3 = (1*pi/180);

const = 0.01;

% Plot the line model
%figure(fig_env); plot_line_segments(REF, LINES, 1);
  
for kk = 2:no_inputs,
    % Check if we should get a position fix, i.e. if the time stamp of the
    % next laser scan is the same as the time stamp of the control input
    % values
    if LD_HEAD(scan_idx,1) == CONTROL(kk,1),
        % Mark the position where the position fix is done - and the size
        % of the position fix to be found
        %figure(fig_path);
        %hold on; plot(X(kk-1), Y(kk-1), 'ro'); hold off;
        %hold on; plot(CONTROL(kk-1,4), CONTROL(kk-1,5), 'ro'); hold off;
        %hold on; plot([X(kk-1) CONTROL(kk-1,4)], [Y(kk-1) CONTROL(kk-1,5)], 'r'); hold off;
        
        % Get the position fix - Use data points that are ok, i.e. with
        % flags = 0
        DATAPOINTS = find(LD_FLAGS(scan_idx,:) == 0);
        angs = LD_ANGLES(scan_idx, DATAPOINTS);
        meas = LD_MEASUR(scan_idx, DATAPOINTS);
        
        % Plot schematic picture of the Snowhite robot
        alfa = 660;
        beta = 0;
        gamma = -90*pi/180;
        %figure(fig_env); plot_line_segments(REF, LINES, 1);
        %plot_threewheeled_Laser([X(kk-1) Y(kk-1) A(kk-1)]', 100, 612, 2, CONTROL(kk-1,5), 150, 50, 680, alfa, beta, gamma, angs, meas, 1);
        LINEMODEL = [REF(LINES(:,1),1:2) REF(LINES(:,2),1:2)];
        % YOU SHOULD WRITE YOUR CODE HERE ....
        [dx dy da C] = Cox_LineFit_2022(angs, meas, [X(kk-1) Y(kk-1) A(kk-1)]',alfa, beta, gamma, LINEMODEL );
        

         %Xhat = X(kk-1);
         %Yhat = Y(kk-1);
         %Ahat = A(kk-1);
         %Sigmahat = P(kk-1,1:9);
         %Sigmahat = reshape(Sigmahat,3,3);
         angDiff = AngDifference(A(kk-1) + da, A(kk-1));
         Xhat = [X(kk-1);Y(kk-1);angDiff];
         Cxya_old = [P(kk-1,1:3);P(kk-1,4:6);P(kk-1,7:9)];
         %Xpf = (CONTROL(kk-1,4) + randn(1,1)*10);
         %Ypf = (CONTROL(kk-1,5) + randn(1,1)*10);
         %Apf = mod(CONTROL(kk-1,6) + randn(1,1)*1, 2*pi);

         %Sigmapf = [randn(1,1)*(sig1^2) 0 0; 
         %           0 randn(1,1)*(sig2^2) 0;
         %           0 0 randn(1,1)*(1^2*pi/180)];
  
         %Sigmapf = reshape(Sigmapf, 3,3); 
         Xpf = [X(kk-1) + dx;
                Y(kk-1) + dy;
                0];
         %CX = [10^2,0,0;0,10^2,0;0,0,(1^2*pi/180)];
         CX = C;
         %Xpred_0 = ((Sigmapf*inv(Sigmapf+Sigmahat))*[Xhat Yhat Ahat]');
         %Xpred_1 = ((Sigmahat*inv(Sigmapf+Sigmahat))*[Xpf Ypf Apf]');
         %Sigma = inv(inv(Sigmapf) + inv(Sigmahat));
         pos_kalman = CX*inv(CX+Cxya_old)*Xhat+Cxya_old*inv(CX+Cxya_old)*Xpf;
         CX = inv(inv(CX)+inv(Cxya_old));
        
        X(kk-1) = pos_kalman(1);
        Y(kk-1) = pos_kalman(2);
        A(kk-1) = mod(A(kk-1) + pos_kalman(3), 2*pi);
        
        P(kk-1,1:9) = [CX(1,1) CX(1,2) CX(1,3) CX(2,1) CX(2,2) CX(2,3) CX(3,1) CX(3,2) CX(3,3)]; % Set current Position unsertainty
        
         %Xpred = Xpred_0 + Xpred_1;
%       
         %xx = Xpred(1);
         %yy = Xpred(2);
         %aa = Xpred(3);
%         
         %X(kk-1) = xx; 
         %Y(kk-1) = yy;
         %A(kk-1) = mod(aa, 2*pi);
         %P(kk-1,1:9) = reshape(Sigma,1,9);
        
        % Next time use the next scan
        scan_idx = mod(scan_idx, max(size(LD_HEAD))) + 1;
    end;
    
    % Mark the estimated (dead reckoning) position
    %figure(fig_path);
    %hold on; plot(X(kk-1), Y(kk-1), 'b.'); hold off;
    % Mark the true (from the LaserWay system) position
    %hold on; plot(CONTROL(kk-1,4), CONTROL(kk-1,5), 'k.'); hold off;
    
    % Estimate the new position (based on the control inputs) and new
    % uncertainty
    v = CONTROL(kk-1,2);
    a = CONTROL(kk-1,3);
    T = 0.050;
    L = 680;

    
    X(kk) = X(kk-1) + v*cos(a)*T*cos(A(kk-1)+v*sin(a)*T/(2*L));
    Y(kk) = Y(kk-1) + v*cos(a)*T*sin(A(kk-1)+v*sin(a)*T/(2*L));
    A(kk) = mod(A(kk-1) +  v*sin(a)*T/L , 2*pi);
    

   Axya = [1 0 -T*v*cos(a)*sin(A(kk-1) + (T*v*sin(a))/(2*L));
           0 1 T*v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a);
           0 0 1];
   
   dXdV = T*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a) - (T^2*v*cos(a)*sin(A(kk-1) + (T*v*sin(a))/(2*L))*sin(a))/(2*L);
   dYdV = T*cos(a)*sin(A(kk-1) + (T*v*sin(a))/(2*L)) + (T^2*v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)*sin(a))/(2*L);
   dAdV = (T*sin(a))/L;
   
   dXdA = -T*v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*sin(a) - (T^2*v^2*cos(a)^2*sin(A(kk-1) + (T*v*sin(a))/(2*L)))/(2*L);
   dYdA = (T^2*v^2*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)^2)/(2*L) - T*v*sin(A(kk-1) + (T*v*sin(a))/(2*L))*sin(a);
   dAdA = (T*v*cos(a))/L;
   
   dXdT = v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a) - (T*v^2*cos(a)*sin(A(kk-1) + (T*v*sin(a))/(2*L))*sin(a))/(2*L);
   dYdT = v*cos(a)*sin(A(kk-1) + (T*v*sin(a))/(2*L)) + (T*v^2*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)*sin(a))/(2*L);
   dAdT =(v*sin(a))/L;

    %       v     a   T
    Avat = [dXdV dXdA dXdT; %X
            dYdV dYdA dYdT; %Y
            dAdV dAdA dAdT];%A
        
    Cvat = [const*abs(v) 0 0;
            0 const*abs(a) 0;
            0 0 const*(T)];
        
        % Predict the new uncertainty in the state variables (Error prediction)
    Cxya_old = [P(kk-1,1:3);P(kk-1,4:6);P(kk-1,7:9)];  % Uncertainty in state variables at time k-1 [3x3]              
    
    % sigma_x_hat 
    % Use the law of error predictions, which gives the new uncertainty
    Cxya_new = Axya*Cxya_old*Axya'+ Avat*Cvat*Avat';
%     
%     % Store the new co-variance matrix
     P(kk,1:9) = [Cxya_new(1,1:3) Cxya_new(2,1:3) Cxya_new(3,1:3)];
      
end;

figure
title('Path taken');
xlabel('X [mm] World co-ordinates');
ylabel('Y [mm] World co-ordinates');
hold on;
for kk = 1:10:no_inputs,
    C = [P(kk,1:3);P(kk,4:6);P(kk,7:9)];
    plot_uncertainty([X(kk) Y(kk) A(kk)]', C, 1, 2);
end;
hold off; 
axis('equal');

ERROR = [X' Y' A'] - CONTROL(:,4:6);
ERROR(:,3) = AngDifference(A',CONTROL(:,6));
ERROR = abs(ERROR);
figure,
subplot(3,1,1);
plot(ERROR(:,1),'b'); hold;
plot(sqrt(P(:,1)),'r'); % one sigma
%plot(ScanPosIndx,sqrt(P(ScanPosIndx,1)),'k.'); % one sigma
title('Error X [mm] and uncertainty [std] (red)');
subplot(3,1,2);
plot(ERROR(:,2),'b'); hold;
plot(sqrt(P(:,5)),'r'); % one sigma
title('Error Y [mm] and uncertainty [std] (red)');
subplot(3,1,3);
plot(ERROR(:,3)*180/pi,'b'); hold;
plot(sqrt(P(:,9))*180/pi,'r'); % one sigma
title('Error A [degree] and uncertainty [std] (red)');