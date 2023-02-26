%
% Odometry with Khepera Mini Robot
%
% Ola Bengtsson, Björn Åstrand
%

clear all;close all;

% %%% Khepera settings 
WHEEL_BASE2 = 45;                % [mm]
WHEEL_DIAMETER2 = 14;          % [mm]
PULSES_PER_REVOLUTION = 600;    %
CANUS = pi*WHEEL_DIAMETER2;
MM_PER_PULSE2 = CANUS/PULSES_PER_REVOLUTION; % [mm / pulse]


WHEEL_BASE = 53;                % [mm]
WHEEL_DIAMETER = 15.3;          % [mm]
PULSES_PER_REVOLUTION = 600;    %
CCP = pi*WHEEL_DIAMETER;
MM_PER_PULSE = CCP/PULSES_PER_REVOLUTION; % [mm / pulse]




% Uncertainty settings, which are be the same for the left and right encoders
SIGMA_WHEEL_ENCODER = 0.5/12;   % The error in the encoder is 0.5mm / 12mm travelled
% Use the same uncertainty in both of the wheel encoders
SIGMAl = SIGMA_WHEEL_ENCODER;
SIGMAr = SIGMA_WHEEL_ENCODER;


% Load encoder values
%ENC = load('khepera_circle.txt');
ENC = load('khepera.txt');


% Transform encoder values (pulses) into distance travelled by the wheels (mm)
Dr = ENC(1:1:end,2) * MM_PER_PULSE;
Dl = ENC(1:1:end,1) * MM_PER_PULSE;

Dr2 = ENC(1:1:end,2) * MM_PER_PULSE2;
Dl2 = ENC(1:1:end,1) * MM_PER_PULSE2;
N = max(size(Dr));

% Init Robot Position, i.e. (0, 0, 90*pi/180) and the Robots Uncertainty
X(1) = 0;
Y(1) = 0;
A(1) = 90*pi/180;

X1(1) = 0;
Y1(1) = 0;
A1(1) = 90*pi/180;


P(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2];
%P2(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2];
P3(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2];
P4(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2];
% Run until no more encoder values are available
disp('Calculating ...');
for kk=2:N,
    % Change of wheel displacements, i.e displacement of left and right wheels
    dDr = Dr(kk) - Dr(kk-1);  
    dDl = Dl(kk) - Dl(kk-1);
    
    
    
    
    dDr2 = Dr2(kk) - Dr2(kk-1);  
    dDl2 = Dl2(kk) - Dl2(kk-1);

    
    % Change of relative movements
    dD = (dDr + dDl)/2; %//Detta har jag lagt in från föreläsning Kinematics and dead reckoning (P.7)
    dD2 = (dDr2 + dDl2)/2;
    %dD = 0;
    
    %Change in the heading angle
    dA = (dDr - dDl)/WHEEL_BASE; %//Detta har jag lagt in från föreläsning Kinematics and dead reckoning (P.7)
    dA2 = (dDr2 - dDl2)/WHEEL_BASE2;
    %dA = 0.017;
    %T(kk) = dA;
    %D(kk) = dD;
    
    % Calculate the change in X and Y (World co-ordinates)
    %dX = 1;
    %dY = 1;
    dX = dD*cos(A(kk-1)+dA/2);
    dY = dD*sin(A(kk-1)+dA/2);
    
    dX2 = dD2*cos(A1(kk-1)+dA2/2);
    dY2 = dD2*sin(A1(kk-1)+dA2/2);
    
    %Added the compensation term / adjustment factor accord. Wang
    %dDX = (sin(dA/2)/(dA/2))*dD*cos(A(kk-1)+dA/2);
    %dDY = (sin(dA/2)/(dA/2))*dD*sin(A(kk-1)+dA/2);
    
    %CT(kk) = (sin(dA/2)/(dA/2));
    
    
    % Predict the new state variables (World co-ordinates)
    X(kk) = X(kk-1) + dX;
    Y(kk) = Y(kk-1) + dY;
    A(kk) = mod(A(kk-1) + dA, 2*pi);
    
    
    X1(kk) = X1(kk-1) + dX2;
    Y1(kk) = Y1(kk-1) + dY2;
    A1(kk) = mod(A1(kk-1) + dA2, 2*pi);
    
    %X1(kk) = X1(kk-1) + dDX;
    %Y1(kk) = Y1(kk-1) + dDY;
    %A1(kk) = mod(A1(kk-1) + dA, 2*pi);
    
    % Predict the new uncertainty in the state variables (Error prediction)
    Cxya_old = [P(kk-1,1:3);P(kk-1,4:6);P(kk-1,7:9)];
    %Cxya_old2 = [P2(kk-1,1:3);P2(kk-1,4:6);P2(kk-1,7:9)];
    Cxya_old3 = [P3(kk-1,1:3);P3(kk-1,4:6);P3(kk-1,7:9)];   % Uncertainty in state variables at time k-1 [3x3]    
    Cxya_old4 = [P4(kk-1,1:3);P4(kk-1,4:6);P4(kk-1,7:9)];   % Uncertainty in state variables at time k-1 [3x3]
    
    CV = (SIGMAr^2 - SIGMAl^2)/(2*WHEEL_BASE);
   
    Cu =   [(SIGMAr^2 - SIGMAl^2)/4 CV; CV (SIGMAr^2 - SIGMAl^2)/(WHEEL_BASE^2)]; % Uncertainty in the input variables [2x2]
    
    
    Axya = [1 0 -dY;0 1 dX;0 0 1];     % Jacobian matrix w.r.t. X, Y and A [3x3] (JXk-1)
    Axya2 = [1 0 -dY2;0 1 dX2;0 0 1];     % Jacobian matrix w.r.t. X, Y and A [3x3] (JXk-1)
    
        
   
    k = 0.01;
    sigB = k*WHEEL_BASE;
    sigB2 = k*WHEEL_BASE2;
    %k = 1;
    
    JdRdL = [0.5*cos(A(kk-1)+dA/2)-(dD/(2*WHEEL_BASE))*sin(A(kk-1)+dA/2) 0.5*cos(A(kk-1)+dA/2)+(dD/(2*WHEEL_BASE))*sin(A(kk-1)+dA/2);
        0.5*sin(A(kk-1)+dA/2)+(dD/(2*WHEEL_BASE))*cos(A(kk-1)+dA/2) 0.5*sin(A(kk-1)+dA/2)-(dD/(2*WHEEL_BASE))*cos(A(kk-1)+dA/2);
        1/WHEEL_BASE -1/WHEEL_BASE];
    
    Cdrdl = [k*abs(dDr) 0;0 k*abs(dDl)];
    
    
    JdRdL2 = [0.5*cos(A1(kk-1)+dA2/2)-(dD2/(2*WHEEL_BASE2))*sin(A1(kk-1)+dA2/2) 0.5*cos(A1(kk-1)+dA2/2)+(dD2/(2*WHEEL_BASE2))*sin(A1(kk-1)+dA2/2);
    0.5*sin(A1(kk-1)+dA2/2)+(dD2/(2*WHEEL_BASE2))*cos(A1(kk-1)+dA2/2) 0.5*sin(A1(kk-1)+dA2/2)-(dD2/(2*WHEEL_BASE2))*cos(A1(kk-1)+dA2/2);
    1/WHEEL_BASE2 -1/WHEEL_BASE2];

    Cdrdl2 = [k*abs(dDr2) 0;0 k*abs(dDl2)];
    

   

    jBB = [((dDr+dDl)/2)*((dDr-dDl)/(2*WHEEL_BASE^2))*sin(A(kk-1)+((dDr-dDl)/(2*WHEEL_BASE)));
        -((dDr+dDl)/2)*((dDr-dDl)/(2*WHEEL_BASE^2))*cos(A(kk-1)+((dDr-dDl)/(2*WHEEL_BASE)));
        -((dDr-dDl)/(WHEEL_BASE^2))];
        
    
    jBB2 = [((dDr2+dDl2)/2)*((dDr2-dDl2)/(2*WHEEL_BASE2^2))*sin(A1(kk-1)+((dDr2-dDl2)/(2*WHEEL_BASE2)));
        -((dDr2+dDl2)/2)*((dDr2-dDl2)/(2*WHEEL_BASE2^2))*cos(A1(kk-1)+((dDr2-dDl2)/(2*WHEEL_BASE2)));
        -((dDr2-dDl2)/(WHEEL_BASE2^2))];
    
   
    
    Au = [cos(A(kk-1)+dA/2) -0.5*dD*sin(A(kk-1)+dA/2);
        sin(A(kk-1)+dA/2) 0.5*dD*cos(A(kk-1)+dA/2);
    0 1];           % Jacobian matrix w.r.t. dD and dA [3x2] (JdDdA)

    %Au2 = [cos(A1(kk-1)+dA2/2) -0.5*dD2*sin(A1(kk-1)+dA2/2);
    %    sin(A1(kk-1)+dA2/2) 0.5*dD2*cos(A1(kk-1)+dA2/2);
    %0 1];           % Jacobian matrix w.r.t. dD and dA [3x2] (JdDdA)

    % Use the law of error predictions, which gives the new uncertainty
    Cxya_new = Axya*Cxya_old*Axya' + Au*Cu*Au'; %For  calculate the variance 
    %Cxya_new2 = Axya2*Cxya_old2*Axya2' + Au2*Cu*Au2'; %For  calculate the variance
    
    Cxya_new3 = Axya*Cxya_old3*Axya' + JdRdL*Cdrdl*JdRdL' + jBB*k*jBB';
    Cxya_new4 = Axya2*Cxya_old4*Axya2' + JdRdL2*Cdrdl2*JdRdL2' + jBB2*k*jBB2';
   
    
    % Store the new co-variance matrix
    P(kk,1:9) = [Cxya_new(1,1:3) Cxya_new(2,1:3) Cxya_new(3,1:3)];
    %P2(kk,1:9) = [Cxya_new2(1,1:3) Cxya_new2(2,1:3) Cxya_new2(3,1:3)];
    P3(kk,1:9)= [Cxya_new3(1,1:3) Cxya_new3(2,1:3) Cxya_new3(3,1:3)];
    P4(kk,1:9)= [Cxya_new4(1,1:3) Cxya_new4(2,1:3) Cxya_new4(3,1:3)];
    % Plotting movement
    plot(X,Y,'black.','MarkerSize',10); % plot path
    plot_khepera([X(kk);Y(kk);A(kk)], WHEEL_DIAMETER, WHEEL_BASE, 3);
    drawnow();
    hold on
    plot(X1,Y1,'green o','MarkerSize',5); % plot path
    plot_khepera([X1(kk);Y1(kk);A1(kk)], WHEEL_DIAMETER2, WHEEL_BASE2, 3);
    drawnow();
    hold off
end;


disp('Plotting ...');

% Plot the path taken by the robot, by plotting the uncertainty in the current position
figure; 
    %plot(X, Y, 'b.');
    title('Path taken by the robot [Wang]');
    xlabel('X [mm] World co-ordinates');
    ylabel('Y [mm] World co-ordinates');
    hold on;
        for kk = 1:1:N,
            C = [P3(kk,1:3);P3(kk,4:6);P3(kk,7:9)];
            C1 = [P4(kk,1:3);P4(kk,4:6);P4(kk,7:9)];
            %C2 = [P(kk,1:3);P(kk,4:6);P(kk,7:9)];
            plot_uncertainty([X(kk) Y(kk) A(kk)]', C, 1, 2,'k'); %Du måste fixa din plot_uncertatiny med en färg så du kan köra koden
            plot_uncertainty([X1(kk) Y1(kk) A1(kk)]', C1, 1, 2,'r'); %Det behövs en extra input i functionen.
            %plot_uncertainty([X(kk) Y(kk) A(kk)]', C2, 1, 2,'r');
        end;
    hold off;
    axis('equal');

    
% After the run, plot the results (X,Y,A), i.e. the estimated positions 
figure;
    subplot(3,1,1); plot(X, 'b'); title('X [mm]');
    subplot(3,1,2); plot(Y, 'b'); title('Y [mm]');
    subplot(3,1,3); plot(A*180/pi, 'b'); title('A [deg]');

% Plot the estimated variances (in X, Y and A) - 1 standard deviation
subplot(3,1,1); hold on;
    plot(X'+sqrt(P(:,1)), 'b:');
    plot(X'-sqrt(P(:,1)), 'b:');
hold off;
subplot(3,1,2); hold on;
    plot(Y'+sqrt(P(:,5)), 'b:');
    plot(Y'-sqrt(P(:,5)), 'b:');
hold off;
subplot(3,1,3); hold on;
    plot((A'+sqrt(P(:,9)))*180/pi, 'b:');
    plot((A'-sqrt(P(:,9)))*180/pi, 'b:');
hold off;
