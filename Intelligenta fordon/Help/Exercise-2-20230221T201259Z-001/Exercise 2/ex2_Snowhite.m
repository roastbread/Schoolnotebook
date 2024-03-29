%
% Dead Reckoning with Snowhite Steed-drive Robot
%
% Bj�rn �strand
%

clear all;
close all;

% %%% Snowhite settings 
L = 680;               % [mm] wheelbase
T = 0.050;             % [sec] Sampling time

% Load encoder values
CONTROL = load('snowhite.txt');

% Init Robot Position, i.e. from Ground Truth
X(1) = CONTROL(1,3);
Y(1) = CONTROL(1,4);
A(1) = CONTROL(1,5);
P(1,1:9) = [1 0 0 0 1 0 0 0 (1*pi/180)^2];

hastighet(1) = 0;
pyt(1) = 0;
% Run until no more values are available, i.e. speed and steering angle
N = max(size(CONTROL)); 
disp('Calculating ...');
for kk=2:N,  
    % Read current control values
    v = CONTROL(kk-1,1); % Speed of the steering wheel
    a = CONTROL(kk-1,2); % Angle of the steering wheel
    
    hastighet(kk) = hastighet(kk-1) + v;
    % Change of relative movements
    dD = v*cos(a)*T;
    dA = (v*sin(a)*T)/L;

    % Calculate the change in X and Y (World co-ordinates)
    dX = dD*cos(A(kk-1)+ (dA/2));
    dY = dD*sin(A(kk-1)+ (dA/2));
    
    pyt(kk) = pyt(kk-1)+sqrt(dX^2+dY^2);

    % Predict the new state variables (World co-ordinates)
    X(kk) = X(kk-1) + dX;
    Y(kk) = Y(kk-1) + dY;
    A(kk) = mod(A(kk-1) + dA, 2*pi);
    
    %syms vv aa TT
    
    %Xk = [X(kk-1)+vv*cos(aa)*TT*cos(A(kk-1)+((vv*sin(aa)*TT)/2*L));Y(kk-1)+vv*cos(aa)*TT*sin(A(kk-1)+((vv*sin(aa)*TT)/2*L));A(kk-1)+((vv*sin(aa)*TT)/L)];
    %v1=[vv aa TT];
    %Au = jacobian(Xk, v1);
   
    % Predict the new uncertainty in the state variables (Error prediction)
    Cxya_old = [P(kk-1,1:3);P(kk-1,4:6);P(kk-1,7:9)];   % Uncertainty in state variables at time k-1 [3x3]    

    
    %Cu =   [k1*abs(v1) 0 0;0 k2 0;0 0 k3];               % Uncertainty in the input variables [3x3]
    k=0.005;
    sigVAT = [k*abs(v) 0 0; 0 k*a 0; 0 0 k*T];
 
    %Axya = [1 0 -dY;0 1 dX;0 0 1];     % Jacobian matrix w.r.t. X, Y and A [3x3] (JXk-1)

    Axya = [1 0 -T*v*sin(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a);
            0 1  T*v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a);
            0 0                                       1];
    %Au=eval(subs(Au,[vv, aa, TT],[v,a,T])); % Jacobian matrix w.r.t. v, a and T [3x2] (JvaT)
   
    jVAT = [0.5*T*cos(a)*(2*cos(T*v*sin(a)/(2*L)+A(kk-1))-T*v*sin(a)*sin(T*v*sin(a)/(2*L)+A(kk-1))) -T*v*(2*L*cos(T*v*sin(a)/(2*L)+A(kk-1))*sin(a)+T*v*cos(a)^2*sin(T*v*sin(a)/(2*L)+A(kk-1)))/(2*L) 0.5*v*cos(a)*(2*cos(T*v*sin(a)/(2*L)+A(kk-1))-T*v*sin(a)*sin(T*v*sin(a)/(2*L)+A(kk-1)));
    (T*cos(a)*(T*v*cos(T*v*sin(a)/(2*L)+A(kk-1))*sin(a)+2*L*sin(T*v*sin(a)/(2*L)+A(kk-1))))/(2*L) (T*v*(T*v*cos(a)^2*cos(T*v*sin(a)/(2*L)+A(kk-1))-2*L*sin(a)*sin(T*v*sin(a)/(2*L)+A(kk-1))))/(2*L) (v*cos(a)*(T*v*cos(T*v*sin(a)/(2*L)+A(kk-1))*sin(a)+2*L*sin(T*v*sin(a)/(2*L)+A(kk-1))))/(2*L);
    T*sin(a)/L T*v*cos(a)/L v*sin(a)/L
    ];
      

    jVAT2 = [T*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a) - (T^2*v*sin(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)*sin(a))/(2*L) -T*v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*sin(a) - (T^2*v^2*sin(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)^2)/(2*L) v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a) - (T*v^2*sin(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)*sin(a))/(2*L);
            T*sin(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a) + (T^2*v*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)*sin(a))/(2*L)   (T^2*v^2*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)^2)/(2*L) - T*v*sin(A(kk-1) + (T*v*sin(a))/(2*L))*sin(a) v*sin(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a) + (T*v^2*cos(A(kk-1) + (T*v*sin(a))/(2*L))*cos(a)*sin(a))/(2*L);
                                                                                              (T*sin(a))/L                                                                                  (T*v*cos(a))/L                                                                                   (v*sin(a))/L];
    
    % Use the law of error predictions, which gives the new uncertainty
    Cxya_new = Axya*Cxya_old*Axya' + jVAT2*sigVAT*jVAT2';
    
    % Store the new co-variance matrix
    P(kk,1:9) = [Cxya_new(1,1:3) Cxya_new(2,1:3) Cxya_new(3,1:3)];
    
    % Plotting movement
    %plot(X,Y,'b.'); hold on; % plot path
    %plot(CONTROL(1:kk-1,3), CONTROL(1:kk-1,4),'k.'); % plot path
    % Plot robot drivning Dead reckoning path
    %plot_threewheeled([X(kk);Y(kk);A(kk)], 100, 612, 2, a, 150, 50, L); 
    % Plot robot drivning Ground Truth path
    %plot_threewheeled([CONTROL(kk-1,3);CONTROL(kk-1,4);CONTROL(kk-1,5)], 100, 612, 2, a, 150, 50, L);
    %drawnow();
end;

conX=CONTROL(end,3)
conY=CONTROL(end,4)
conA=CONTROL(end,5)

predX=X(end)
predY=Y(end)
predA=A(end)

eX=conX-predX
eY=conY-predY
eA=conA-predA

sd=[sqrt(P(end,1)),sqrt(P(end,4)),sqrt(P(end,7))]
disp('Plotting ...');

% Plot the path taken by the robot, by plotting the uncertainty in the current position
figure; 
    plot(X, Y, 'b.'); hold on; % By dead reconing 
    plot(CONTROL(:,3),CONTROL(:,4),'k.'); % Ground Truth
    title('Path taken by the robot [Wang]');
    xlabel('X [mm] World co-ordinates');
    ylabel('Y [mm] World co-ordinates');
    diffX(1) = 0;
    diffA(1) = 0;
    diffY(1) = 0;
    hold on;
        for kk = 1:5:N, % Change the step to plot less seldom, i.e. every 5th
            C = [P(kk,1:3);P(kk,4:6);P(kk,7:9)];
            plot_uncertainty([X(kk) Y(kk) A(kk)]', C, 1, 2,'r') %Du m�ste fixa din plot_uncertatiny med en f�rg s� du kan k�ra koden
            %diffX(kk) = ((X(kk)-CONTROL(kk,3)));               %Det beh�vs en extra input i functionen.
            %diffY(kk) = ((Y(kk)-CONTROL(kk,4)));
            %diffA(kk) = ((A(kk)-CONTROL(kk,5)));
        end;
    hold off;
    axis('equal');
    
        
% figure;
%  subplot(3,1,1); histogram(diffX,15,'FaceColor',"black"); title('X [mm]');
%  subplot(3,1,2); histogram(diffY,15,'FaceColor',"black"); title('Y [mm]');
%  subplot(3,1,3); histogram(diffA,15,'FaceColor',"black"); title('A [mm]');
% 
%  
% figure;
%  subplot(3,1,1); plot(diffX, 'k'); title('X [mm]');
%  subplot(3,1,2); plot(diffY, 'k'); title('Y [mm]');
%  subplot(3,1,3); plot(diffA, 'k'); title('A [mm]');
% 
% subplot(3,1,1); hold on;
%     plot(sqrt(P(:,1)), 'r:');
%     plot(-sqrt(P(:,1)), 'r:');
% hold off;
% 
% 
% subplot(3,1,3);hold on;
%     plot(sqrt(P(:,9)), 'r:');
%     plot(-sqrt(P(:,9)), 'r:');
% hold off;
% 
% subplot(3,1,2);hold on;
%     plot(sqrt(P(:,5)), 'r:');
%     plot(-sqrt(P(:,5)), 'r:');
% hold off;

% After the run, plot the results (X,Y,A), i.e. the estimated positions 
figure;
    subplot(3,1,1); plot(X, 'k'); title('X [mm]');
    subplot(3,1,2); plot(Y, 'k'); title('Y [mm]');
    subplot(3,1,3); plot(A*180/pi, 'k'); title('A [deg]');

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
