%
% Fits (by translation and rotation) data points to a set of 
% line segments, i.e. applying the Cox's algorithm
% function [ddx,ddy,dda,C] = Cox_LineFit(ANG, DIS, POSE, LINEMODEL, SensorPose)
% 
function [ddx,ddy,dda,C] = Cox_LineFit(ANG, DIS, POSE, LINEMODEL, SensorPose)
    % Init variables
    ddx = 0; ddy = 0; dda = 0;
    Rx = POSE(1,1); Ry = POSE(2,1); Ra = POSE(3,1); 
    sALFA = SensorPose(1); sBETA = SensorPose(2); sGAMMA = SensorPose(3);
    max_iterations = 10; % <------YOU NEED TO CHANGE THIS NUMBER
    no_update = 0;
    
    % Step 0 - Normal vectors (length = 1) to the line segments
    % -> Add your code here
    rot_mat = [0, -1;1, 0];
    for i = 1: 16
       p1(i,1:2) = LINEMODEL(i,1:2);
       p2(i,1:2) = LINEMODEL(i,3:4);
       Lin(i,1:2) = p2(i,1:2)-p1(i,1:2);
       u(i,1:2) = ((rot_mat*Lin(i,1:2)')/norm(Lin(i,1:2)));
       dista(i) = dot(u(i,1:2), p1(i,1:2));

    end
    
    
    % The Loop - REPEAT UNTIL THE PROCESS CONVERGE
    for iteration = 1:max_iterations,
        X_world = zeros(length(DIS), 5);
        vi_L = zeros(1, 5);
        % Step 1 Translate and rotate data points
            % 1.1) Relative measurements => Sensor co-ordinates
        for i = 1: length(DIS)    
            x = DIS(i)*cos(ANG(i));
            y = DIS(i)*sin(ANG(i));
   
            % 1.2) Sensor co-ordinates => Robot co-ordinates
            %-> Add your code here
            R = [cos(sGAMMA) -sin(sGAMMA) sALFA; sin(sGAMMA) cos(sGAMMA) sBETA; 0 0 1];

            X_robot = R*[x y 1]';

            % 1.3) Robot co-ordinates => World co-ordinates
            %-> Add your code here
            R = [cos(Ra+dda) -sin(Ra+dda) Rx+ddx; sin(Ra+dda) cos(Ra+dda) Ry+ddy; 0 0 1];

            Ws = R*[X_robot(1) X_robot(2) 1]';

            % X_world[meas index, x in World, y in world, assigned Line, outlier threshold] 
            X_world(i,1:5) = [i, Ws(1), Ws(2), -1, 20000];

      
        % Step 2 Find targets for data points
        %-> Add your code here

            for j = 1:16
                disty = dista(j) - dot(u(j,:),X_world(i, 2:3));
                if abs(disty) <= abs(X_world(i,5))
                    X_world(i,4) = j;
                    X_world(i,5) = disty;
                end
            end
        end

        medi = median(abs(X_world(:,5)));
        array_counter = 1;
        for i = 1:length(X_world)
            if abs(X_world(i,5)) < medi
                vi_L(array_counter, 1:5) = X_world(i, 1:5);
                array_counter = array_counter + 1;
            end
        end    
        testing = vi_L(:,5);
        %vi_L is the new matrix containing all the points assigned to lines
        %with outliers removed, it looks like: index, X, Y, line, distance
        %to line.

        % Step 3 Set up linear equation system, find b = (dx,dy,da)' from the LS
        %-> Add your code here
        xi1 = zeros(size(vi_L,1),1);
        xi2 = zeros(size(vi_L,1),1);
        xi3 = zeros(size(vi_L,1),1);
        for i = 1:size(vi_L,1)
            xi1(i) = u(vi_L(i,4),1);
            xi2(i) = u(vi_L(i,4),2);
            ui = [u(vi_L(i,4),1), u(vi_L(i,4),2)];
            vi = vi_L(i,2:3)';
            xi3(i) = ui*rot_mat*(vi-[Rx+ddx,Ry+ddy]');
        end

        A = [xi1, xi2, xi3];
        b = (A'*A)\A'*vi_L(:,5)
        
        %b = POSE/max_iterations; % <--- You shall change this! This is only
        % for demonstation, i.e. return the same pose as sent in.
        S2 = (vi_L(:,5)-A*b)'*(vi_L(:,5)-A*b)/(max(size(A)));
        C = S2*inv(A'*A);
        %C = 0; % Covarince matrix
        
        % Step 4 Add latest contribution to the overall congruence 
        ddx = ddx + b(1);
        ddy = ddy + b(2);
        dda = dda + b(3);
        % Step 5  Check if the process has converged
        %-> Add your code here
        
        if (sqrt(b(1)^2+b(2)^2) < 5) && (abs(b(3)) <0.1*pi/180)
            stopping=iteration
            break
        end
        
    end

    