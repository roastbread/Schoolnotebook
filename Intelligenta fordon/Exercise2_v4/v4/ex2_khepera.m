%
% Odometry with Khepera Mini Robot
%
% Ola Bengtsson, Björn Åstrand
%

clear all;
close all;

ENC = 'khepera_circle.txt';
[P, X, Y, A, N, dD, dA] = kephera_p_one(ENC, 1, 1);
md = mean(dD);
ma = mean(dA);
ea = A(end);
ey = Y(end);
ex = X(end);
hold off
ENC = 'khepera.txt';
[P2, X2, Y2, A2, N2] = kephera_p_two(ENC, 53, 15.3);
[P3, X3, Y3, A3, N3] = kephera_p_two(ENC, 45, 14);

plot(X2,Y2,'k'); % plot path
hold on
plot(X3,Y3,'r'); % plot path


disp('Plotting ...');

% Plot the path taken by the robot, by plotting the uncertainty in the current position
figure; 
    %plot(X, Y, 'b.');
    title('Path taken by the robot [Wang]');
    xlabel('X [mm] World co-ordinates');
    ylabel('Y [mm] World co-ordinates');
    hold on;
        for kk = 1:1:N,
            C = [P(kk,1:3);P(kk,4:6);P(kk,7:9)];
            plot_uncertainty([X(kk) Y(kk) A(kk)]', C, 1, 2, 'k');
        end;
    hold off;
    axis('equal');
figure; 
    %plot(X, Y, 'b.');
    title('Path taken by the robot [Wang]');
    xlabel('X [mm] World co-ordinates');
    ylabel('Y [mm] World co-ordinates');
    hold on;
        for kk = 1:1:N2,
            C1 = [P2(kk,1:3);P2(kk,4:6);P2(kk,7:9)];
            plot_uncertainty([X2(kk) Y2(kk) A2(kk)]', C1, 1, 2, 'k');
            C2 = [P3(kk,1:3);P3(kk,4:6);P3(kk,7:9)];
            plot_uncertainty([X3(kk) Y3(kk) A3(kk)]', C2, 1, 2, 'r');
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


function [P, X, Y, A, N, dd, da] = kephera_p_one(ENC, compensation, interval)

% %%% Khepera settings 
WHEEL_BASE = 53;                % [mm]
WHEEL_DIAMETER = 15.3;          % [mm]
PULSES_PER_REVOLUTION = 600;    %
MM_PER_PULSE = WHEEL_DIAMETER*pi/PULSES_PER_REVOLUTION ;               % [mm / pulse]
%MM_PER_PULSE = ??; % You should write the correct one, which replaces the one above!


% %%% Uncertainty settings, which are be the same for the left and right encoders
SIGMA_WHEEL_ENCODER = 0.5/12;   % The error in the encoder is 0.5mm / 12mm travelled
% Use the same uncertainty in both of the wheel encoders
SIGMAl = SIGMA_WHEEL_ENCODER;
SIGMAr = SIGMA_WHEEL_ENCODER;


% Load encoder values
ENC = load(ENC);


% Transform encoder values (pulses) into distance travelled by the wheels (mm)
Dr = ENC(1:interval:end,2) * MM_PER_PULSE;
Dl = ENC(1:interval:end,1) * MM_PER_PULSE;
N = max(size(Dr));

% Init Robot Position, i.e. (0, 0, 90*pi/180) and the Robots Uncertainty
X(1) = 0;
Y(1) = 0;
A(1) = 90*pi/180;
P(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2];

% Run until no more encoder values are available
disp('Calculating ...');
for kk=2:N,
    % Change of wheel displacements, i.e displacement of left and right wheels
    dDr = Dr(kk) - Dr(kk-1);
    dDl = Dl(kk) - Dl(kk-1);
    
    % Change of relative movements
    dD = (dDr + dDl)/2;
    dA = (dDr - dDl)/WHEEL_BASE;
    dd(kk) = dD;
    da(kk) = dA;
    if compensation == 1
        comp = (sin(dA/2+realmin)/(dA/2+realmin));
    else
        comp = 1;
    end

    % Calculate the change in X and Y (World co-ordinates)
    dX = dD * comp * cos(A(kk-1) + dA/2);
    dY = dD * comp * sin(A(kk-1) + dA/2);
    

    % Predict the new state variables (World co-ordinates)
    X(kk) = X(kk-1) + dX;
    Y(kk) = Y(kk-1) + dY;
    A(kk) = mod(A(kk-1) + dA, 2*pi);
    % Predict the new uncertainty in the state variables (Error prediction)
    Cxya_old = [P(kk-1,1:3);P(kk-1,4:6);P(kk-1,7:9)];   % Uncertainty in state variables at time k-1 [3x3]    
    CV =   (SIGMAr^2 - SIGMAl^2)/(2 * WHEEL_BASE);
    Cu =   [(SIGMAr^2 + SIGMAl^2)/4, CV;
            CV, (SIGMAr^2 - SIGMAl^2)/WHEEL_BASE^2];               % Uncertainty in the input variables [2x2]
    Axya = [1, 0, -comp * dD*sin(A(kk-1) + dA/2);
            0, 1, comp * dD*cos(A(kk-1) + dA/2);
            0, 0, 1];     % Jacobian matrix w.r.t. X, Y and A [3x3]
    Au =   [comp * cos(A(kk-1) + dA/2), comp * (-dD/2)*sin(A(kk-1) + dA/2); 
            comp * sin(A(kk-1) + dA/2), comp * (dD/2)*cos(A(kk-1) + dA/2);
            0, 1];           % Jacobian matrix w.r.t. dD and dA [3x2]
    
    % Use the law of error predictions, which gives the new uncertainty
    Cxya_new = Axya*Cxya_old*Axya' + Au*Cu*Au';
    
    % Store the new co-variance matrix
    P(kk,1:9) = [Cxya_new(1,1:3) Cxya_new(2,1:3) Cxya_new(3,1:3)];
    
    % Plotting movement
    plot(X,Y,'k.'); % plot path
    plot_khepera([X(kk);Y(kk);A(kk)], WHEEL_DIAMETER, WHEEL_BASE, 3);
    drawnow();
end
end

function [P, X, Y, A, N] = kephera_p_two(ENC, WHEEL_BASE, WHEEL_DIAMETER)
% %%% Khepera settings 
PULSES_PER_REVOLUTION = 600;    %
MM_PER_PULSE = WHEEL_DIAMETER*pi/PULSES_PER_REVOLUTION ;               % [mm / pulse]

% Load encoder values
ENC = load(ENC);

% Transform encoder values (pulses) into distance travelled by the wheels (mm)
Dr = ENC(1:1:end,2) * MM_PER_PULSE;
Dl = ENC(1:1:end,1) * MM_PER_PULSE;
N = max(size(Dr));

% Init Robot Position, i.e. (0, 0, 90*pi/180) and the Robots Uncertainty
X(1) = 0;
Y(1) = 0;
A(1) = 90*pi/180;
P(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2];

% Run until no more encoder values are available
disp('Calculating ...');
for kk=2:N,
    % Change of wheel displacements, i.e displacement of left and right wheels
    dDr = Dr(kk) - Dr(kk-1);
    dDl = Dl(kk) - Dl(kk-1);
    
    % Change of relative movements
    dD = (dDr + dDl)/2;
    dA = (dDr - dDl)/WHEEL_BASE;

    % Calculate the change in X and Y (World co-ordinates)
    dX = dD * cos(A(kk-1) + dA/2);
    dY = dD * sin(A(kk-1) + dA/2);
    
    % Predict the new state variables (World co-ordinates)
    X(kk) = X(kk-1) + dX;
    Y(kk) = Y(kk-1) + dY;
    A(kk) = mod(A(kk-1) + dA, 2*pi);
    
    % Predict the new uncertainty in the state variables (Error prediction)
    Cxya_old = [P(kk-1,1:3);P(kk-1,4:6);P(kk-1,7:9)];   % Uncertainty in state variables at time k-1 [3x3] 

    k = 0.01;
    Cu =   [k*abs(dDr), 0;
            0, k*abs(dDl)];               % Uncertainty in the input variables [2x2]
    Cb =   k * WHEEL_BASE;

    Jxya = [1 0 -dD*sin(A(kk-1) + dA/2);
            0 1 dD*cos(A(kk-1) + dA/2);
            0 0 1];     % Jacobian matrix w.r.t. X, Y and A [3x3]

    Ju =   [cos(A(kk-1) - (dDl-dDr)/(2*WHEEL_BASE))/2 - (sin(A(kk-1) - (dDl-dDr)/(2*WHEEL_BASE)) * (dDl/2 + dDr/2))/(2*WHEEL_BASE), cos(A(kk-1) - (dDl-dDr)/(2*WHEEL_BASE))/2 + (sin(A(kk-1)-(dDl-dDr)/(2*WHEEL_BASE)) * (dDl/2 + dDr/2))/(2*WHEEL_BASE);
            sin(A(kk-1) - (dDl-dDr)/(2*WHEEL_BASE))/2 + (cos(A(kk-1)-(dDl-dDr)/(2*WHEEL_BASE)) * (dDl/2 + dDr/2))/(2*WHEEL_BASE), sin(A(kk-1) - (dDl-dDr)/(2*WHEEL_BASE))/2 - (cos(A(kk-1)-(dDl-dDr)/(2*WHEEL_BASE)) * (dDl/2 + dDr/2))/(2*WHEEL_BASE);
            1/WHEEL_BASE, -1/WHEEL_BASE];           % Jacobian matrix w.r.t. dD and dA [3x2]
    Jb =   [-(sin(A(kk-1) - (dDl-dDr)/(2*WHEEL_BASE)) * (dDl-dDr) * (dDl/2 + dDr/2))/(2*WHEEL_BASE^2);
            (cos(A(kk-1) - (dDl-dDr)/(2*WHEEL_BASE)) * (dDl-dDr) * (dDl/2 + dDr/2))/(2*WHEEL_BASE^2);
            (dDl-dDr)/(WHEEL_BASE^2)];

    % Use the law of error predictions, which gives the new uncertainty
    Cxya_new = Jxya*Cxya_old*Jxya' + Ju*Cu*Ju' + Jb*Cb*Jb';
    
    % Store the new co-variance matrix
    P(kk,1:9) = [Cxya_new(1,1:3) Cxya_new(2,1:3) Cxya_new(3,1:3)];
    
    % Plotting movement
end
end
