function [ddx ddy dda C] = Cox_LineFit_2022(angs, meas, X ,alfa, beta, gamma, LINEMODEL)
%COX_LINEFIT Summary of this function goes here 
%   Detailed explanation goes here
ddx=0;
ddy=0;
dda=0;
S = 0;

%STEP 0: Calculate all unit vectors of all lines 
%rotate_matrix = [cosd(-90) -sind(-90);
%                sind(-90) cosd(-90)];
%            
rotate_matrix = [cos(pi/2) -sin(pi/2);
                sin(pi/2) cos(pi/2)];
%unit_vectors = zeros(max(size(LINEMODEL)), 2);
k = 1;   
%figure,  
clear y_no_outliers A B uni_temp y_smallest Xw y_find ind y_find_smallest;

    for i=1:max(size(LINEMODEL)),
        x0 = LINEMODEL(i,1);
        y0 = LINEMODEL(i,2);
        x1 = LINEMODEL(i,3);
        y1 = LINEMODEL(i,4);
        %hold on;

        %Move points to origo
        %x0_new = x0-x0; %fett onödigt för det är ju 0
        x1_new = x0-x1;
        %y0_new = y0-y0; %fett onödigt för det är ju 0
        y1_new = y0 - y1;

        vectors = [x1_new y1_new]*rotate_matrix;

        %make vectors unitvectors
        unit = vectors/(sqrt(x1_new^2+y1_new^2));%norm(vectors);
        unit_vectors(k,1) = unit(1);
        unit_vectors(k,2) = unit(2);
        
        k=k+1;
    end

    for n_lines=1:max(size(LINEMODEL)),
          %r(n_lines) = abs(dot((LINEMODEL(n_lines,3:4)),unit_vectors(n_lines,1:2)));
          r(n_lines) = abs(dot(unit_vectors(n_lines,1:2),(LINEMODEL(n_lines,1:2)))); 
    end
    
h = 0;
for testing=1:20,
    %Step 1 - translate and rotate data points 
    %Sensor values to Cartesian coordinates, x=r*cos(alpha), y=r*sin(alpha)
        x = meas.*cos(angs);
        y = meas.*sin(angs);
        
    %the loop: 
    for kk=1:max(size(meas)),
    
        Am = [x(kk) y(kk) 1];
        %Xw(kk,1:3) = Am(kk);
        %Xw_temp = Xw(kk,1:2);
        
    %Sensor coordinates to robot coordinates, R = [cos(Sa) ?sin(Sa) Sx; sin(Sa)
    %cos(Sa) Sy;0 0 1], Xs = R*[x y 1]T
    %sa? Sx? Sy?...
         R = [cos(gamma) -sin(gamma) alfa;       
             sin(gamma) cos(gamma) beta;
             0 0 1];
         
         %Am = [x y 1]; 
         Xs = R*Am';
 

%     %Robot coordinates to world coordinates, 
%     %need to know the robot position in the world coordinate, borde vara X som
%     %vi ska använda oss av..
%     %R = [cos(?) ?sin(?) Xr(1); sin(?) cos(?) Xr(2);0 0 1], 
%     %Xw = R*[Xs(1) Xs(2) 1]T
         R = [cos(X(3)+dda) -sin(X(3)+dda) X(1)+ddx;
              sin(X(3)+dda) cos(X(3)+dda)  X(2)+ddy;
              0 0 1];

         Xw(kk,1:3) = R*[Xs(1) Xs(2) 1]';
         Xw_temp = Xw(kk,1:2);
         
% 
%     %STEP 2 - Find the target for data points
    for n_datapoints=1:max(size(unit_vectors)),
        y_find(kk,n_datapoints) = (r(n_datapoints)-(dot(unit_vectors(n_datapoints,1:2),Xw_temp))); 
    end

        [y_smallest ind] = min(abs(y_find),[],2);

        for n_smallest=1:max(size(y_smallest)),
            y_find_smallest(n_smallest) = y_find(n_smallest,ind(n_smallest));
        end


    Xw_1 = mean(Xw(:,1));
    Xw_2 = mean(Xw(:,2));
    temp_Xw(1:2) = [Xw_1 Xw_2];

    end
    
    find_outliers = mean(y_smallest);
    mm = 1;
    
    for j=1:max(size(y_find_smallest)),
         if (y_smallest(j) < find_outliers ),
             y_no_outliers(mm,1+h) = y_find_smallest(j);
             y_no_outliers(mm,2+h) = ind(j);    
             mm=mm+1;
        end
    end
    
    %STEP 3 - Set up linear equation system
       
    for i=1:mm-1%max(size(y_no_outliers(1+h))), %mm-1
        uni_temp(i,1:2) = unit_vectors(y_no_outliers(i,2+h),1:2);
        
        Xi(i,1) = uni_temp(i,1);
        Xi(i,2) = uni_temp(i,2);
        ui = unit_vectors(y_no_outliers(i,2+h),1:2);
        
        matri = [0 -1; 
                 1 0];
             
        subs = Xw(i,1:2) - temp_Xw;
        
        Xi(i,3) = (ui*matri*subs');

        A(i,1) = Xi(i,1);
        A(i,2) = Xi(i,2);
        A(i,3) = Xi(i,3);
    end
       ata = A(:,1:3)'*A(:,1:3);
       B = inv(ata)*(A(:,1:3))'*y_no_outliers(:,1+h);
       S = ((y_no_outliers(:,1+h)-(A(:,1:3)*B))' * (y_no_outliers(:,1+h) - (A(:,1:3)*B)))/(max(size(A))-4);
           %STEP 4 - Add latest contribution to the overall congruence
           ddx = ddx + B(1);
           ddy = ddy + B(2);
           dda = mod(dda + B(3),2*pi);
      
           C = S*inv(ata);     
      
            %STEP 5 - Check if the process has converged
            if(sqrt(B(1)^2 + B(2)^2)<5) && (abs(B(3)) < 0.1*pi/180),
                 break;
            end 
     
    h=h+2; 
  
    end
    

    
end

