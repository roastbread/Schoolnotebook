
s=1.4; %standard deviation 
%Next, we calculate coordinates of grid point by meshgrid function which needs the size of the grid,
%which in turn is determined by s. At 3*s a gaussian is 0.01, so the omitted parts of the gaussian
%are practically zero. 
[xg,yg]=meshgrid(-round(3*s):round(3*s),-round(3*s):round(3*s));
[x,y]=meshgrid(-round(3*s):round(3*s),-round(3*s):round(3*s)); 
g=exp(-(x.*x + y.*y)/(2*s*s)); %This yields a 2D smoothing filter 
g=g/sum(sum(g)); % sum of weights equals one 
figure(1); subplot(2,1,1);mesh(xg,yg,g); %show the filter 